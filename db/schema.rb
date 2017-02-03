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

ActiveRecord::Schema.define(:version => 20170108054414) do

  create_table "relationships", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "relationships", ["from_id"], :name => "index_relationships_on_from_id"
  add_index "relationships", ["to_id"], :name => "index_relationships_on_to_id"

  create_table "resources", :force => true do |t|
    t.integer  "path_id"
    t.boolean  "used"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tasks", :force => true do |t|
    t.text     "ids"
    t.integer  "total"
    t.integer  "crawled"
    t.boolean  "finished"
    t.string   "percentage"
    t.time     "start_at"
    t.time     "finish_at"
    t.integer  "used"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "gender"
    t.string   "birth"
    t.string   "hometown"
    t.string   "address"
    t.string   "school"
    t.integer  "level"
    t.boolean  "crawled",    :default => false
    t.integer  "parent_id"
    t.string   "name"
    t.boolean  "dispatched", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

end
