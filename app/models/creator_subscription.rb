class CreatorSubscription < ApplicationRecord
  belongs_to :subscription_plan
  belongs_to :subscriber, class_name: "User"
  validates :status, inclusion: { in: %w[active canceled past_due] }
end
