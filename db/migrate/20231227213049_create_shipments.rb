class CreateShipments < ActiveRecord::Migration[7.1]
  def change
    create_table :shipments do |t|
      t.string :ship_method
      t.integer :order_id
      t.integer :address_id

      t.timestamps
    end
  end
end
