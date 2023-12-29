class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country_code
      t.string :email
      t.string :phone_number

      t.timestamps
    end
  end
end
