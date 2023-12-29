class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.integer :customer_id
      t.string :order_external_id
      t.decimal :order_total

      t.timestamps
    end
  end
end
