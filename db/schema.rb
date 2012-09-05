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

ActiveRecord::Schema.define(:version => 20120905005729) do

  create_table "articles", :force => true do |t|
    t.string   "arxiv_id"
    t.text     "title"
    t.text     "abstract"
    t.text     "comments"
    t.string   "doi"
    t.string   "journal_ref"
    t.string   "report_no"
    t.string   "submitter"
    t.string   "primary_category"
    t.string   "msc_class"
    t.string   "acm_class"
    t.datetime "published"
    t.datetime "last_updated"
    t.integer  "scites"
  end

  add_index "articles", ["arxiv_id"], :name => "index_articles_on_arxiv_id", :unique => true
  add_index "articles", ["last_updated"], :name => "index_articles_on_last_updated"
  add_index "articles", ["primary_category", "published", "scites"], :name => "index_articles_on_primary_category_and_published_and_scites"
  add_index "articles", ["primary_category", "scites", "published"], :name => "index_articles_on_primary_category_and_scites_and_published"
  add_index "articles", ["published"], :name => "index_articles_on_published"

  create_table "authors", :force => true do |t|
    t.string  "name"
    t.string  "institution"
    t.integer "article_id"
  end

  add_index "authors", ["article_id"], :name => "index_authors_on_article_id"

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.integer "article_id"
  end

  add_index "categories", ["article_id"], :name => "index_categories_on_article_id"

  create_table "crawls", :force => true do |t|
    t.datetime "finished"
    t.datetime "max_published"
    t.datetime "max_updated"
  end

  add_index "crawls", ["finished"], :name => "index_crawls_on_finished"

  create_table "event_params", :force => true do |t|
    t.string  "key"
    t.text    "str_value"
    t.integer "int_value"
    t.float   "float_value"
    t.integer "event_id"
  end

  add_index "event_params", ["event_id"], :name => "index_event_params_on_event_id"

  create_table "events", :force => true do |t|
    t.string   "activity"
    t.datetime "at"
    t.float    "duration"
    t.integer  "user_id"
  end

  add_index "events", ["activity"], :name => "index_events_on_activity"
  add_index "events", ["at"], :name => "index_events_on_at"

  create_table "interests", :force => true do |t|
    t.string   "category"
    t.boolean  "primary"
    t.datetime "last_seen"
    t.integer  "user_id"
  end

  add_index "interests", ["user_id"], :name => "index_interests_on_user_id"

  create_table "model_params", :force => true do |t|
    t.string  "key"
    t.float   "value"
    t.integer "model_id"
  end

  add_index "model_params", ["model_id"], :name => "index_model_params_on_model_id"

  create_table "models", :force => true do |t|
    t.string  "method"
    t.integer "interest_id"
  end

  add_index "models", ["interest_id"], :name => "index_models_on_interest_id"

  create_table "ratings", :force => true do |t|
    t.integer "article_id"
    t.integer "action"
    t.integer "user_id"
  end

  add_index "ratings", ["user_id"], :name => "index_ratings_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "allow_email"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "name"
    t.string   "size"
    t.datetime "timestamp"
    t.integer  "article_id"
  end

  add_index "versions", ["article_id"], :name => "index_versions_on_article_id"

end
