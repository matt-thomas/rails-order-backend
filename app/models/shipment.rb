class Shipment < ApplicationRecord
    belongs_to :order
    belongs_to :address
end
