class CreatePlayerSeasonStats < ActiveRecord::Migration[7.1]
  def change
    return if table_exists?(:player_season_stats)
    create_table :player_season_stats do |t|
      t.integer :nba_player_id, null: false
      t.string :season_id
      t.integer :games_played
      t.float :total_minutes
      t.float   :pts
      t.float   :reb
      t.float   :ast
      t.float   :stl
      t.float   :blk
      t.float :tov
      t.float :fg_pct
      t.float :fg3_pct
      t.float :ft_pct
    end

    add_index :player_season_stats, [:nba_player_id, :season_id], unique: true
  end
end
