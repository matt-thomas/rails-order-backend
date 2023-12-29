class AddUniqueness < ActiveRecord::Migration[7.1]
  def change
    add_index :customers, :customer_external_id, :unique => true
    add_index :orders, :order_external_id, :unique => true
    # add_reference :shipments, :orders, foreign_key: true
    # add_reference :shipments, :addresses, foreign_key: true
    # add_reference :featured_products, :products, foreign_key: true
    # add_reference :orders, :customers, foreign_key: true
    # add_reference :line_items, :orders, foreign_key: true
    # add_reference :line_items, :products, foreign_key: true
  end
end
