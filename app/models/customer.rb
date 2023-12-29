class Customer < ApplicationRecord
    has_many :orders
    validates :customer_external_id, presence: true, uniqueness: true
end
