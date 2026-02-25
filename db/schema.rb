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

ActiveRecord::Schema[8.1].define(version: 2026_02_19_032455) do
  create_table "fuel_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "gallons", precision: 6, scale: 3
    t.datetime "log_date"
    t.integer "miles"
    t.decimal "mpg", precision: 4, scale: 1
    t.integer "odometer"
    t.decimal "price_per_gallon", precision: 6, scale: 3
    t.decimal "total_cost", precision: 7, scale: 2
    t.datetime "updated_at", null: false
    t.integer "vehicle_id", null: false
    t.index ["vehicle_id"], name: "index_fuel_logs_on_vehicle_id"
  end

  create_table "reminder_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "miles"
    t.integer "next_odometer"
    t.text "notes"
    t.integer "reminder_type_id", null: false
    t.integer "service_type_id", null: false
    t.integer "time"
    t.datetime "updated_at", null: false
    t.integer "vehicle_id", null: false
    t.index ["reminder_type_id"], name: "index_reminders_on_reminder_type_id"
    t.index ["service_type_id"], name: "index_reminders_on_service_type_id"
    t.index ["vehicle_id"], name: "index_reminders_on_vehicle_id"
  end

  create_table "service_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "log_date"
    t.text "notes"
    t.integer "odometer"
    t.integer "service_type_id", null: false
    t.decimal "total_cost", precision: 7, scale: 2
    t.datetime "updated_at", null: false
    t.integer "vehicle_id", null: false
    t.index ["service_type_id"], name: "index_service_logs_on_service_type_id"
    t.index ["vehicle_id"], name: "index_service_logs_on_vehicle_id"
  end

  create_table "service_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "current_odometer"
    t.string "make"
    t.string "model"
    t.integer "oil_change_frequency"
    t.integer "tire_rotation_frequency"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "year"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
  end

  add_foreign_key "fuel_logs", "vehicles"
  add_foreign_key "reminders", "reminder_types"
  add_foreign_key "reminders", "service_types"
  add_foreign_key "reminders", "vehicles"
  add_foreign_key "service_logs", "service_types"
  add_foreign_key "service_logs", "vehicles"
  add_foreign_key "vehicles", "users"
end
