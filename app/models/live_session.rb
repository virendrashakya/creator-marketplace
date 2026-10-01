class LiveSession < ApplicationRecord
  belongs_to :user
  # Optional: when set, only subscribers to this one plan get in, rather than
  # anyone with any active plan.
  belongs_to :subscription_plan, optional: true
  has_many :live_messages, dependent: :destroy

  STATUSES = %w[scheduled live ended canceled].freeze
  ACCESS = %w[members public].freeze

  validates :title, presence: true, length: { maximum: 140 }
  validates :description, length: { maximum: 1_000 }
  validates :scheduled_for, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :access, inclusion: { in: ACCESS }
  # A plan from another creator would silently let nobody in.
  validate :plan_belongs_to_creator

  scope :upcoming, -> { where(status: "scheduled").order(:scheduled_for) }
  scope :airing, -> { where(status: "live") }
  # What the public page lists: anything not cancelled, soonest first, with
  # finished lives last.
  scope :visible, -> { where.not(status: "canceled") }

  def live? = status == "live"
  def scheduled? = status == "scheduled"
  def ended? = status == "ended"
  def canceled? = status == "canceled"
  def members_only? = access == "members"

  # Whether `viewer` may see the stream itself. This is the paywall, and it
  # is the only place that decides: the controller and both views ask this
  # rather than reimplementing the rule.
  #
  # Deliberately separate from `joinable?`: being allowed to watch is about
  # who you are, being able to watch is about whether the live is on.
  def watchable_by?(viewer)
    return true unless members_only?
    return false if viewer.blank?
    # The creator always gets into their own room.
    return true if viewer == user

    if subscription_plan.present?
      viewer.subscribed_to?(subscription_plan)
    else
      viewer.subscribed_to_creator?(user)
    end
  end

  # Whether there is anything to watch right now. A member still cannot join
  # a live that has not started or has finished.
  def joinable? = live?

  # Chat is open while the live is on, to the same people who may watch it,
  # unless the creator has turned it off or narrowed it. A finished live
  # keeps its transcript readable but takes no new messages: a chat that
  # outlives the broadcast is a different feature (direct messages) and has
  # its own door.
  def chattable_by?(viewer)
    return false unless live? && viewer.present?
    # The creator is never locked out of their own room by their own switches:
    # turning chat off is how they quieten the audience, not themselves, and
    # they still need to be able to say "back in five minutes".
    return true if viewer == user

    return false unless chat_enabled?
    return false unless watchable_by?(viewer)
    # "Members only" chat on an already-members-only live is a no-op, and on
    # a public live it is the point: anyone may watch, members may speak.
    return viewer.subscribed_to_creator?(user) if chat_members_only?

    true
  end

  # Whether the transcript is still shown after the broadcast. A creator can
  # choose for a live to leave nothing behind.
  def transcript_visible?
    return true unless ended?

    keep_chat_after?
  end

  # Whether this appears on the creator's public page. Unlisted is not a
  # paywall: it only means the link is the only way in.
  def listed? = !unlisted?

  # Why someone cannot watch, for the view to explain. Returning a symbol
  # rather than a sentence keeps the copy in the template.
  def block_reason_for(viewer)
    return nil if watchable_by?(viewer)
    return :sign_in if viewer.blank?

    :subscribe
  end

  def start!
    update!(status: "live", started_at: Time.current)
  end

  def end!
    update!(status: "ended", ended_at: Time.current)
  end

  private

  def plan_belongs_to_creator
    return if subscription_plan.blank? || user_id.blank?
    return if subscription_plan.user_id == user_id

    errors.add(:subscription_plan, "must be one of your own plans")
  end
end
