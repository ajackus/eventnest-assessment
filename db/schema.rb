# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_04_04_100000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_bookmarks_on_event_id"
    t.index ["user_id", "event_id"], name: "index_bookmarks_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "venue"
    t.string "city"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "status"
    t.string "category"
    t.integer "max_capacity"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "ticket_tier_id", null: false
    t.integer "quantity"
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["ticket_tier_id"], name: "index_order_items_on_ticket_tier_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.string "status"
    t.decimal "total_amount", precision: 10, scale: 2
    t.string "confirmation_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_orders_on_event_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.string "status"
    t.string "provider_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "failure_reason"
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "ticket_tiers", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name"
    t.decimal "price", precision: 10, scale: 2
    t.integer "quantity", default: 0
    t.integer "sold_count", default: 0
    t.datetime "sales_start"
    t.datetime "sales_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_ticket_tiers_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bookmarks", "events"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "events", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "ticket_tiers"
  add_foreign_key "orders", "events"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "ticket_tiers", "events"
end
