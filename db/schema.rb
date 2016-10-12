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

ActiveRecord::Schema.define(version: 20161012113149) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "unaccent"

  create_table "collections", force: :cascade do |t|
    t.text "name",               null: false
    t.text "department"
    t.text "extent"
    t.text "abstract"
    t.text "dates"
    t.text "unitid"
    t.text "acquisition_info"
    t.text "preferred_citation"
    t.text "other_finding_aids"
    t.text "related_material"
    t.text "arrangement"
  end

  create_table "people", force: :cascade do |t|
    t.text    "name",                           null: false
    t.text    "born"
    t.text    "died"
    t.text    "other",                                       array: true
    t.hstore  "identifiers",       default: {}, null: false
    t.integer "collections_count", default: 0,  null: false
    t.text    "other_names",       default: [], null: false, array: true
  end

  create_table "people_in_collections", force: :cascade do |t|
    t.integer "person_id",     null: false
    t.integer "collection_id", null: false
    t.text    "as",            null: false
    t.index ["person_id", "collection_id"], name: "index_people_in_collections_on_person_id_and_collection_id", unique: true, using: :btree
  end

  add_foreign_key "people_in_collections", "collections", on_delete: :cascade
  add_foreign_key "people_in_collections", "people", on_delete: :cascade
end
