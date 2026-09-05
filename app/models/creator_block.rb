class CreatorBlock < ApplicationRecord
  belongs_to :creator, class_name: "User"
  validates :identifier_type, inclusion: { in: %w[username email phone] }
  validates :identifier_value, presence: true, uniqueness: { scope: %i[creator_id identifier_type] }
  before_validation :normalize_identifier

  private

  def normalize_identifier
    self.identifier_value = case identifier_type
    when "email" then identifier_value.to_s.downcase.strip
    when "username" then identifier_value.to_s.downcase.strip.delete_prefix("@")
    when "phone" then identifier_value.to_s.gsub(/\D/, "")
    else identifier_value.to_s.strip
    end
  end
end
