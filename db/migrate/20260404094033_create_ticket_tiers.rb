class CreateTicketTiers < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_tiers do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity, default: 0
      t.integer :sold_count, default: 0
      t.datetime :sales_start
      t.datetime :sales_end

      t.timestamps
    end
  end
end
