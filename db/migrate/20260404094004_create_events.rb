class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :venue
      t.string :city
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :status
      t.string :category
      t.integer :max_capacity
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
