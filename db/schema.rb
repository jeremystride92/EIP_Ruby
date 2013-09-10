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

ActiveRecord::Schema.define(:version => 20130910162453) do

  create_table "benefits", :force => true do |t|
    t.string   "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "beneficiary_id"
    t.string   "beneficiary_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "benefits", ["beneficiary_type", "beneficiary_id"], :name => "index_benefits_on_beneficiary_type_and_beneficiary_id"
  add_index "benefits", ["beneficiary_type"], :name => "index_benefits_on_beneficiary_type"

  create_table "card_levels", :force => true do |t|
    t.string   "name"
    t.integer  "venue_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "theme"
    t.integer  "daily_guest_pass_count", :default => 0
    t.integer  "sort_position"
  end

  add_index "card_levels", ["venue_id"], :name => "index_card_levels_on_venue_id"

  create_table "card_levels_promotions", :id => false, :force => true do |t|
    t.integer "card_level_id", :null => false
    t.integer "promotion_id",  :null => false
  end

  add_index "card_levels_promotions", ["card_level_id"], :name => "index_card_levels_promotions_on_card_level_id"
  add_index "card_levels_promotions", ["promotion_id"], :name => "index_card_levels_promotions_on_promotion_id"

  create_table "card_themes", :force => true do |t|
    t.string   "name"
    t.integer  "venue_id"
    t.string   "portrait_background"
    t.string   "landscape_background"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "card_themes", ["venue_id"], :name => "index_card_themes_on_venue_id"

  create_table "cardholders", :force => true do |t|
    t.string   "phone_number"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "photo"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "password_digest"
    t.string   "auth_token"
    t.string   "status"
    t.string   "onboarding_token"
    t.datetime "activated_at"
    t.string   "reset_token"
    t.datetime "reset_token_date"
  end

  add_index "cardholders", ["auth_token"], :name => "index_cardholders_on_auth_token"
  add_index "cardholders", ["phone_number"], :name => "index_cardholders_on_phone_number"

  create_table "cards", :force => true do |t|
    t.integer  "card_level_id"
    t.integer  "cardholder_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "guest_count",   :default => 0
    t.integer  "issuer_id"
    t.string   "status"
    t.datetime "issued_at"
  end

  add_index "cards", ["card_level_id"], :name => "index_cards_on_card_level_id"
  add_index "cards", ["cardholder_id"], :name => "index_cards_on_cardholder_id"

  create_table "guest_passes", :force => true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "card_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "guest_passes", ["card_id"], :name => "index_guest_passes_on_card_id"

  create_table "partners", :force => true do |t|
    t.string   "name"
    t.string   "phone_number"
    t.integer  "venue_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "default_guest_count"
    t.text     "default_benefits"
  end

  add_index "partners", ["venue_id"], :name => "index_partners_on_venue_id"

  create_table "promotions", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "image"
    t.integer  "venue_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "promotions", ["venue_id"], :name => "index_promotions_on_venue_id"

  create_table "temporary_cards", :force => true do |t|
    t.string   "phone_number"
    t.integer  "partner_id"
    t.integer  "issuer_id"
    t.integer  "guest_count"
    t.string   "access_token"
    t.datetime "expires_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "id_token"
  end

  add_index "temporary_cards", ["partner_id"], :name => "index_temporary_cards_on_partner_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "auth_token"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "roles_mask"
    t.integer  "venue_id"
    t.string   "reset_token"
    t.datetime "reset_token_date"
    t.string   "name"
  end

  add_index "users", ["auth_token"], :name => "index_users_on_auth_token"

  create_table "venues", :force => true do |t|
    t.string   "name"
    t.string   "logo"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "phone"
    t.string   "location"
    t.string   "address1"
    t.string   "address2"
    t.string   "website"
    t.string   "vanity_slug"
    t.string   "nexmo_number"
    t.string   "time_zone"
  end

  add_index "venues", ["vanity_slug"], :name => "index_venues_on_vanity_slug"

end
