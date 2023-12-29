class Order < ApplicationRecord
    belongs_to :customer
    has_many :line_items, dependent: :delete_all
    has_many :shipments, dependent: :delete_all
    validates :order_external_id, uniqueness: true
    # TODO add class method to calculate order total on save.
end
