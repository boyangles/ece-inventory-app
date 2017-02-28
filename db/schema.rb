# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170226181722) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "custom_fields", force: :cascade do |t|
    t.string  "field_name",                        null: false
    t.boolean "private_indicator", default: false, null: false
    t.integer "field_type",        default: 0,     null: false
    t.index ["field_name"], name: "index_custom_fields_on_field_name", unique: true, using: :btree
  end

  create_table "item_custom_fields", force: :cascade do |t|
    t.integer "item_id"
    t.integer "custom_field_id"
    t.text    "short_text_content"
    t.text    "long_text_content"
    t.integer "integer_content"
    t.float   "float_content"
    t.index ["custom_field_id"], name: "index_item_custom_fields_on_custom_field_id", using: :btree
    t.index ["item_id", "custom_field_id"], name: "index_item_custom_fields_on_item_id_and_custom_field_id", unique: true, using: :btree
    t.index ["item_id"], name: "index_item_custom_fields_on_item_id", using: :btree
  end

  create_table "item_logs", force: :cascade do |t|
    t.integer "log_id"
    t.integer "item_id"
    t.integer "action"
    t.integer "quantity_change"
    t.string  "old_name"
    t.string  "new_name"
    t.string  "old_desc"
    t.string  "new_desc"
    t.string  "old_model_num"
    t.string  "new_model_num"
    t.integer "curr_quantity"
    t.index ["item_id"], name: "index_item_logs_on_item_id", using: :btree
    t.index ["log_id"], name: "index_item_logs_on_log_id", using: :btree
  end

  create_table "item_tags", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_tags_on_item_id", using: :btree
    t.index ["tag_id"], name: "index_item_tags_on_tag_id", using: :btree
  end

  create_table "items", force: :cascade do |t|
    t.string  "unique_name"
    t.integer "quantity"
    t.string  "description"
    t.string  "model_number"
    t.integer "status",       default: 0
    t.integer "last_action"
  end

  create_table "logs", force: :cascade do |t|
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id"
    t.integer  "log_type",   default: 0
    t.index ["user_id"], name: "index_logs_on_user_id", using: :btree
  end

  create_table "request_items", force: :cascade do |t|
    t.integer  "request_id"
    t.integer  "item_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "quantity",   default: 0
    t.index ["item_id"], name: "index_request_items_on_item_id", using: :btree
    t.index ["request_id"], name: "index_request_items_on_request_id", using: :btree
  end

  create_table "request_logs", force: :cascade do |t|
    t.integer "log_id"
    t.integer "request_id"
    t.integer "action"
    t.index ["log_id"], name: "index_request_logs_on_log_id", using: :btree
    t.index ["request_id"], name: "index_request_logs_on_request_id", using: :btree
  end

  create_table "requests", force: :cascade do |t|
    t.string   "reason"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "status",       default: 0
    t.integer  "request_type", default: 0
    t.string   "response"
    t.integer  "user_id"
    t.index ["user_id"], name: "index_requests_on_user_id", using: :btree
  end

  create_table "stack_exchanges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_logs", force: :cascade do |t|
    t.integer  "log_id"
    t.integer  "user_id"
    t.integer  "action"
    t.integer  "old_privilege"
    t.integer  "new_privilege"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["log_id"], name: "index_user_logs_on_log_id", using: :btree
    t.index ["user_id"], name: "index_user_logs_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "password_digest"
    t.string   "email"
    t.integer  "status",          default: 0
    t.integer  "privilege",       default: 0
    t.string   "confirm_token"
    t.string   "auth_token",      default: ""
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "item_custom_fields", "custom_fields"
  add_foreign_key "item_custom_fields", "items"
  add_foreign_key "item_logs", "logs"
  add_foreign_key "request_logs", "logs"
  add_foreign_key "requests", "users"
  add_foreign_key "user_logs", "logs"
end
