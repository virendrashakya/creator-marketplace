class Event < ApplicationRecord
  self.table_name = "events"

  ACTIONS = %w[
    profile_view
    collection_view collection_unlock
    drop_view media_view media_download
    post_view post_like post_unlike post_comment
    follow unfollow
    subscribe subscribe_renew subscribe_expire
    message_send
    link_list_open link_list_tap
    share
    live_join live_leave live_gift
    spoil_me_gift
    pay_start pay_submit pay_approve pay_reject
    pwa_install push_subscribe search
  ].freeze

  belongs_to :actor, class_name: "User"
  belongs_to :creator, class_name: "User", optional: true
  belongs_to :target, polymorphic: true, optional: true

  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :actor_id, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_creator, ->(creator_id) { where(creator_id: creator_id) }
  scope :for_actor, ->(actor_id) { where(actor_id: actor_id) }
  scope :action_is, ->(action) { where(action: action) }
  scope :in_period, ->(range) { where(created_at: range) }

  # Helper to track an event asynchronously or synchronously
  def self.track(action:, actor:, creator: nil, target: nil, properties: {}, request: nil, session_id: nil)
    actor_id = actor.is_a?(User) ? actor.id : actor
    creator_id = creator.is_a?(User) ? creator.id : creator
    target_type = target&.class&.name
    target_id = target&.id

    device_type = "web"
    ip_hash = nil
    referrer = nil

    if request
      user_agent = request.user_agent.to_s.downcase
      device_type = if user_agent.include?("wishful-pwa") || request.headers["X-Requested-With"] == "wishful-pwa"
                      "pwa"
                    elsif user_agent.include?("mobile") || user_agent.include?("android") || user_agent.include?("iphone")
                      "mobile_browser"
                    else
                      "desktop"
                    end
      ip_hash = Digest::SHA256.hexdigest(request.remote_ip.to_s)[0..15] if request.remote_ip.present?
      referrer = request.referer
    end

    create!(
      actor_id: actor_id,
      creator_id: creator_id,
      action: action.to_s,
      target_type: target_type,
      target_id: target_id,
      properties: properties || {},
      source: properties[:source] || "direct",
      referrer: referrer || properties[:referrer],
      device_type: properties[:device_type] || device_type,
      ip_hash: ip_hash,
      session_id: session_id,
      created_at: Time.current
    )
  end
end
