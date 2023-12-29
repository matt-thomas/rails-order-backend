class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :product_name
      t.string :sku
      t.string :product_type
      t.decimal :price

      t.timestamps
    end
  end
end
