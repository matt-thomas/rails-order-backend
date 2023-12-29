class Customer < ApplicationRecord
    has_many :orders
    validates :customer_external_id, uniqueness: true
end
