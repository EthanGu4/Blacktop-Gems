# 20260115010101_create_active_nba_players.rb
class CreateActiveNbaPlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :active_nba_players do |t|
      t.integer :nba_player_id, null: false
      t.string  :first_name
      t.string  :last_name
      t.string  :full_name
      t.boolean  :is_active
      t.integer  :team_id
      t.string  :team_abbreviation
    end

    add_index :active_nba_players, :nba_player_id, unique: true
  end
end
