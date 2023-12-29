class FeaturedProduct < ApplicationRecord
    belongs_to :product
    validates :month, presence: true, uniqueness: true
end
