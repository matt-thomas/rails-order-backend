class LineItem < ApplicationRecord
    belongs_to :order
    belongs_to :product
    validates :product_id, :order_id, :quantity, :price, presence: true
    validates :quantity, :price, numericality: { greater_than_or_equal_to: 0 }
end
