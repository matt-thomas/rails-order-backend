class Shipment < ApplicationRecord
    belongs_to :order
    belongs_to :address
    validates :ship_method, :order_id, :address_id, presence: true
end
