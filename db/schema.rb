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

ActiveRecord::Schema.define(version: 20160722155203) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bots", force: :cascade do |t|
    t.integer  "status",     default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "platform"
    t.integer  "time_left",  default: 0
    t.integer  "user_id"
    t.datetime "last_run"
  end

  add_index "bots", ["user_id"], name: "index_bots_on_user_id", using: :btree

  create_table "twitter_bots", force: :cascade do |t|
    t.text     "tags",                  default: [],                                 array: true
    t.boolean  "follow_back",           default: true
    t.integer  "follow_method",         default: 0
    t.integer  "frequency",             default: 0
    t.integer  "bot_id"
    t.integer  "twitter_client_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "follow",                default: true
    t.boolean  "unfollow",              default: true
    t.boolean  "like",                  default: false
    t.integer  "days_since_follow",     default: 4
    t.string   "tags_for_likes",        default: [],                                 array: true
    t.datetime "following_updated_at",  default: '2016-07-22 19:55:14'
    t.boolean  "is_updating_following", default: false
    t.datetime "followers_updated_at",  default: '2016-07-22 19:55:14'
    t.boolean  "is_updating_followers", default: false
  end

  create_table "twitter_clients", force: :cascade do |t|
    t.integer  "twitter_id",                   limit: 8
    t.string   "twitter_oauth_token"
    t.string   "twitter_oauth_token_secret"
    t.string   "twitter_oauth_token_verifier"
    t.text     "twitter_oauth_authorize_url"
    t.boolean  "connected"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "twitter_bot_id"
    t.string   "username"
  end

  add_index "twitter_clients", ["twitter_bot_id"], name: "index_twitter_clients_on_twitter_bot_id", using: :btree

  create_table "twitter_users", force: :cascade do |t|
    t.integer  "twitter_id",                   limit: 8
    t.string   "tag_followed"
    t.string   "twitter_client"
    t.integer  "follow_status",                          default: 0
    t.datetime "followed_at"
    t.string   "username"
    t.string   "name"
    t.string   "url"
    t.string   "followers_count"
    t.string   "location"
    t.datetime "created_at",                                         null: false
    t.string   "description"
    t.string   "lang"
    t.string   "time_zone"
    t.string   "verified"
    t.string   "profile_image_url"
    t.string   "website"
    t.string   "statuses_count"
    t.string   "profile_background_image_url"
    t.string   "profile_banner_url"
    t.datetime "updated_at",                                         null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.integer  "role"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "bots", "users"
end
