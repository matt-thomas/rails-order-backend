class Product < ApplicationRecord
    has_many :line_items
    has_many :featured_products
end
