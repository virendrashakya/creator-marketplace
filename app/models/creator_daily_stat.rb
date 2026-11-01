class CreatorDailyStat < ApplicationRecord
  belongs_to :creator, class_name: "User"

  validates :date, presence: true
  validates :creator_id, uniqueness: { scope: :date, message: "already has stats for this date" }

  scope :for_period, ->(range) { where(date: range).order(date: :asc) }
  scope :last_7_days, -> { where("date >= ?", 7.days.ago.to_date).order(date: :asc) }
  scope :last_30_days, -> { where("date >= ?", 30.days.ago.to_date).order(date: :asc) }
  scope :last_90_days, -> { where("date >= ?", 90.days.ago.to_date).order(date: :asc) }
  scope :this_month, -> { where("date >= ?", Date.current.beginning_of_month).order(date: :asc) }
  scope :last_month, -> { where(date: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).order(date: :asc) }

  def total_revenue
    total_revenue_cents / 100.0
  end
end
