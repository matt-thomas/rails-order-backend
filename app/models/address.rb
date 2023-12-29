class Address < ApplicationRecord
    has_one :shipment
    validates :name, :address1, :city, :state, :postal_code, :country_code, :email, :phone_number, presence: true
end
