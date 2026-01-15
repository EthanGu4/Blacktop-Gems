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

ActiveRecord::Schema[8.1].define(version: 2026_01_14_204902) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_nba_players", id: :serial, force: :cascade do |t|
    t.text "first_name", null: false
    t.text "full_name", null: false
    t.boolean "is_active", default: true, null: false
    t.text "last_name", null: false
    t.integer "nba_player_id", null: false
    t.string "team_abbreviation", limit: 3
    t.integer "team_id"

    t.unique_constraint ["nba_player_id"], name: "active_nba_players_nba_player_id_key"
  end

  create_table "active_players", id: :serial, force: :cascade do |t|
    t.integer "balldontlie_player_id"
    t.text "first_name", null: false
    t.text "last_name", null: false
    t.text "team_abbr", null: false
    t.index ["balldontlie_player_id"], name: "index_active_players_on_balldontlie_player_id", unique: true, where: "(balldontlie_player_id IS NOT NULL)"
    t.index ["first_name", "last_name", "team_abbr"], name: "unique_player_identity", unique: true
  end

  create_table "player_game_stats", id: :serial, force: :cascade do |t|
    t.integer "ast"
    t.integer "blk"
    t.integer "fg3_attempted"
    t.integer "fg3_made"
    t.integer "fg_attempted"
    t.integer "fg_made"
    t.integer "ft_attempted"
    t.integer "ft_made"
    t.date "game_date", null: false
    t.text "game_id", null: false
    t.text "minutes"
    t.integer "nba_player_id", null: false
    t.integer "plus_minus"
    t.integer "pts"
    t.integer "reb"
    t.integer "stl"
    t.integer "tov"
    t.index ["game_date"], name: "idx_game_stats_date"
    t.unique_constraint ["game_id", "nba_player_id"], name: "unique_game_player"
  end

  create_table "player_season_stats", id: :serial, force: :cascade do |t|
    t.decimal "ast"
    t.decimal "blk"
    t.decimal "fg3_pct"
    t.decimal "fg_pct"
    t.decimal "ft_pct"
    t.integer "games_played"
    t.integer "nba_player_id", null: false
    t.decimal "pts"
    t.decimal "reb"
    t.text "season_id", null: false
    t.decimal "stl"
    t.decimal "total_minutes"
    t.decimal "tov"
    t.index ["nba_player_id"], name: "idx_player_season_player"
    t.index ["season_id"], name: "idx_season_stats_season"
    t.unique_constraint ["nba_player_id", "season_id"], name: "unique_player_season"
  end

  add_foreign_key "player_game_stats", "active_nba_players", column: "nba_player_id", primary_key: "nba_player_id", name: "fk_player_game", on_delete: :cascade
  add_foreign_key "player_season_stats", "active_nba_players", column: "nba_player_id", primary_key: "nba_player_id", name: "fk_player", on_delete: :cascade
end
