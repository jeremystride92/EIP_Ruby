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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130606142705) do

  create_table "card_levels", :force => true do |t|
    t.string   "name"
    t.integer  "venue_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "benefits"
  end

  add_index "card_levels", ["venue_id"], :name => "index_card_levels_on_venue_id"

  create_table "cardholders", :force => true do |t|
    t.string   "phone_number"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "photo"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "cardholders", ["phone_number"], :name => "index_cardholders_on_phone_number"

  create_table "cards", :force => true do |t|
    t.integer  "card_level_id"
    t.integer  "cardholder_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "cards", ["card_level_id"], :name => "index_cards_on_card_level_id"
  add_index "cards", ["cardholder_id"], :name => "index_cards_on_cardholder_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "auth_token"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "venues", :force => true do |t|
    t.string   "name"
    t.string   "logo"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "phone"
    t.string   "location"
    t.string   "address1"
    t.string   "address2"
    t.string   "website"
    t.string   "vanity_slug"
    t.integer  "owner_id"
  end

end
