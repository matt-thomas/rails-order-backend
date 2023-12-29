class CreateFeaturedProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :featured_products do |t|
      t.integer :product_id
      t.integer :month

      t.timestamps
    end
  end
end
