class FeaturedProduct < ApplicationRecord
    belongs_to :product
    validates :month, :year, presence: true
end
