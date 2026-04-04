class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :status
      t.decimal :total_amount, precision: 10, scale: 2
      t.string :confirmation_number

      t.timestamps
    end
  end
end
