class LinkClick < ApplicationRecord
  belongs_to :product_link, counter_cache: :clicks_count
end
