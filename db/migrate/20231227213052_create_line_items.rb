class CreateLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :line_items do |t|
      t.integer :product_id
      t.integer :order_id
      t.integer :quantity
      t.decimal :price

      t.timestamps
    end
  end
end
