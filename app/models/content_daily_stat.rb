class ContentDailyStat < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :content, polymorphic: true

  validates :date, presence: true
  validates :content_id, uniqueness: { scope: [:content_type, :date], message: "already has stats for this date" }

  scope :for_period, ->(range) { where(date: range).order(date: :asc) }
  scope :for_content, ->(item) { where(content_type: item.class.name, content_id: item.id) }
  scope :collections, -> { where(content_type: "PaidMediaCollection") }
  scope :posts, -> { where(content_type: "CreatorPost") }
  scope :link_lists, -> { where(content_type: "LinkList") }
  scope :top_earning, ->(limit = 5) { group(:content_type, :content_id).order(Arel.sql("SUM(revenue_cents) DESC")).limit(limit) }

  def conversion_rate
    return 0.0 if pay_sheet_opens.zero?
    ((conversions.to_f / pay_sheet_opens) * 100).round(2)
  end
end
