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

ActiveRecord::Schema[8.1].define(version: 2026_01_14_120501) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_nba_players", force: :cascade do |t|
    t.string "first_name"
    t.string "full_name"
    t.boolean "is_active"
    t.string "last_name"
    t.integer "nba_player_id", null: false
    t.string "team_abbreviation"
    t.integer "team_id"
    t.index ["nba_player_id"], name: "index_active_nba_players_on_nba_player_id", unique: true
  end

  create_table "active_players", id: :serial, force: :cascade do |t|
    t.integer "balldontlie_player_id"
    t.text "first_name", null: false
    t.text "last_name", null: false
    t.text "team_abbr", null: false
    t.index ["balldontlie_player_id"], name: "index_active_players_on_balldontlie_player_id", unique: true, where: "(balldontlie_player_id IS NOT NULL)"
    t.index ["first_name", "last_name", "team_abbr"], name: "unique_player_identity", unique: true
  end

  create_table "player_game_stats", force: :cascade do |t|
    t.float "ast"
    t.float "blk"
    t.integer "fg3_attempted"
    t.integer "fg3_made"
    t.integer "fg_attempted"
    t.integer "fg_made"
    t.integer "ft_attempted"
    t.integer "ft_made"
    t.date "game_date", null: false
    t.string "game_id", null: false
    t.string "minutes"
    t.integer "nba_player_id", null: false
    t.integer "plus_minus"
    t.float "pts"
    t.float "reb"
    t.float "stl"
    t.integer "tov"
    t.index ["game_date"], name: "index_player_game_stats_on_game_date"
    t.index ["nba_player_id", "game_id"], name: "index_player_game_stats_on_nba_player_id_and_game_id", unique: true
  end

  create_table "player_season_stats", force: :cascade do |t|
    t.float "ast"
    t.float "blk"
    t.float "fg3_pct"
    t.float "fg_pct"
    t.float "ft_pct"
    t.integer "games_played"
    t.integer "nba_player_id", null: false
    t.float "pts"
    t.float "reb"
    t.string "season_id"
    t.float "stl"
    t.float "total_minutes"
    t.float "tov"
    t.index ["nba_player_id", "season_id"], name: "index_player_season_stats_on_nba_player_id_and_season_id", unique: true
  end
end
