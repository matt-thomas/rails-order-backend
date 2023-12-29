class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :customer_external_id

      t.timestamps
    end
  end
end
