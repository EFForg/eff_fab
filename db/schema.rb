# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160419182514) do

  create_table "fabs", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "period"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "gif_tag_file_name"
    t.string   "gif_tag_content_type"
    t.integer  "gif_tag_file_size"
    t.datetime "gif_tag_updated_at"
  end

  add_index "fabs", ["period"], name: "index_fabs_on_period"
  add_index "fabs", ["user_id"], name: "index_fabs_on_user_id"

  create_table "notes", force: :cascade do |t|
    t.integer  "fab_id"
    t.text     "body"
    t.boolean  "forward"
    t.boolean  "achivement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "notes", ["fab_id"], name: "index_notes_on_fab_id"

  create_table "teams", force: :cascade do |t|
    t.text     "name"
    t.integer  "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 191, default: "", null: false
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "name"
    t.integer  "role"
    t.integer  "team_id"
    t.string   "title"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["team_id"], name: "index_users_on_team_id"

end
