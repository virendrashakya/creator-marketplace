class CreatorPost < ApplicationRecord
  belongs_to :user, counter_cache: :posts_count
  # A free post can tease a paid collection; the post page links to it.
  belongs_to :paid_media_collection, optional: true
  has_one_attached :media
  has_many :creator_post_likes, dependent: :destroy
  has_many :creator_post_comments, dependent: :destroy
  has_many :post_bookmarks, dependent: :destroy

  POST_TYPES = %w[post poll audio video_teaser live_replay].freeze
  validates :body, presence: true, length: { maximum: 2_200 }
  validates :post_type, inclusion: { in: POST_TYPES }, allow_blank: true
  validate :collection_belongs_to_author

  after_create_commit :enqueue_feed_fanout, if: :published?

  def video?
    media.attached? && media.content_type.to_s.start_with?("video/")
  end

  def audio?
    media.attached? && media.content_type.to_s.start_with?("audio/")
  end

  def tags
    custom = read_attribute(:tags)
    return custom if custom.present? && custom.any?
    extracted = body.to_s.scan(/#\w+/)
    extracted.any? ? extracted : ["#AfterDark", "#VIPVault", "#Exclusive"]
  end

  def item_type
    return post_type if post_type.present? && post_type != "post"
    if audio? || body.to_s.downcase.include?("audio") || body.to_s.downcase.include?("whisper")
      "audio"
    elsif video?
      "video_teaser"
    elsif body.to_s.downcase.include?("poll:") || body.to_s.downcase.include?("grwm poll")
      "poll"
    else
      "post"
    end
  end

  def category
    lower = body.to_s.downcase
    if lower.include?("close friends") || lower.include?("vip")
      "close_friends"
    elsif lower.include?("vault") || lower.include?("teaser")
      "teasers"
    elsif lower.include?("spicy") || lower.include?("sensual") || lower.include?("lingerie") || lower.include?("chiffon")
      "spicy"
    else
      "all"
    end
  end

  def badge
    return metadata["badge"] if metadata.is_a?(Hash) && metadata["badge"].present?
    case item_type
    when "poll" then "INTERACTIVE RUNWAY POLL"
    when "audio" then "AUDIO WHISPER DROP"
    when "video_teaser" then "60FPS 4K UHD TEASER"
    else "4K UHD • RAW EDIT"
    end
  end

  def poll_question
    metadata.is_a?(Hash) && metadata["poll_question"].presence || body.to_s.sub(/^(GRWM poll|Poll):\s*/i, "")
  end

  def poll_options
    if metadata.is_a?(Hash) && metadata["poll_options"].is_a?(Array) && metadata["poll_options"].any?
      metadata["poll_options"]
    else
      ["Option A", "Option B"]
    end
  end

  def poll_duration
    metadata.is_a?(Hash) && metadata["poll_duration"].presence || "24 hours"
  end

  def audio_title
    metadata.is_a?(Hash) && metadata["audio_title"].presence || "Bedside Confessions (Uncut)"
  end

  def audio_format
    metadata.is_a?(Hash) && metadata["audio_format"].presence || "3D Binaural • FLAC Lossless"
  end

  def drop_id_tag
    metadata.is_a?(Hash) && metadata["asset_code"].presence || "##{user.handle.upcase}-POST-#{id}"
  end

  def title
    metadata.is_a?(Hash) && metadata["title"].presence || body.to_s.lines.first.to_s.truncate(60)
  end

  def wardrobe_tags
    if metadata.is_a?(Hash) && metadata["wardrobe_tags"].is_a?(Array) && metadata["wardrobe_tags"].any?
      metadata["wardrobe_tags"]
    else
      [
        { "code" => "W-01", "name" => "Silk Velvet Corset Blouse", "source" => "Nykaa Luxe • Styled for midnight analog capture" },
        { "code" => "W-02", "name" => "Handcrafted Silver Kamarbandh", "source" => "FabIndia Atelier Collection • Antique Silver 925" }
      ]
    end
  end

  def visibility
    metadata.is_a?(Hash) && metadata["visibility"].presence || "public"
  end

  def pinned?
    metadata.is_a?(Hash) && [true, "true", "1", 1].include?(metadata["pin_to_profile"])
  end

  def retention_percentage
    return metadata["retention_rate"].to_i if metadata.is_a?(Hash) && metadata["retention_rate"].present?
    78 + (id * 7 % 18)
  end

  def asset_code
    case item_type
    when "poll" then "#POL-#{1000 + id % 9000}"
    when "audio" then "#AUD-#{1000 + id % 9000}"
    when "video_teaser" then "#VID-#{1000 + id % 9000}"
    else
      paid_media_collection.present? ? "#VLT-#{1000 + id % 9000}" : "#PST-#{1000 + id % 9000}"
    end
  end

  def revenue_cents
    if paid_media_collection.present?
      paid_media_collection.price_cents * paid_media_collection.unlocks_count
    else
      # Estimate or tip revenue based on likes and comments
      (likes_count.to_i * 1200 + comments_count.to_i * 3500)
    end
  end

  private

  def enqueue_feed_fanout
    FeedFanoutJob.perform_later("CreatorPost", id, "post")
  end

  def collection_belongs_to_author
    return if paid_media_collection.blank? || paid_media_collection.user_id == user_id

    errors.add(:paid_media_collection, "is not yours")
  end
end
