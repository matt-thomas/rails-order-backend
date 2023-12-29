class Product < ApplicationRecord
    has_many :line_items
    has_many :featured_products
    validates :product_name, :product_type, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :sku, presence: true, uniqueness: true
end
