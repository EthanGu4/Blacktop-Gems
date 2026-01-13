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

ActiveRecord::Schema[8.1].define(version: 2026_01_12_233000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_players", id: :serial, force: :cascade do |t|
    t.integer "balldontlie_player_id"
    t.text "first_name", null: false
    t.text "last_name", null: false
    t.text "team_abbr", null: false
    t.index ["balldontlie_player_id"], name: "index_active_players_on_balldontlie_player_id", unique: true, where: "(balldontlie_player_id IS NOT NULL)"
    t.index ["first_name", "last_name", "team_abbr"], name: "unique_player_identity", unique: true
  end
end
