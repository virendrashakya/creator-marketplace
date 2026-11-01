class ReferralDailyStat < ApplicationRecord
  belongs_to :creator, class_name: "User"

  validates :date, presence: true
  validates :source, presence: true
  validates :source, uniqueness: { scope: [:creator_id, :date], message: "already has stats for this date and source" }

  scope :for_period, ->(range) { where(date: range).order(date: :asc) }
  scope :for_creator, ->(creator_id) { where(creator_id: creator_id) }
  scope :top_sources, -> { group(:source).select("source, SUM(visits) as total_visits, SUM(unlocks) as total_unlocks, SUM(revenue_cents) as total_revenue_cents").order(Arel.sql("SUM(revenue_cents) DESC")) }
end
