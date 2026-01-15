class NameUniqueIndexForPlayerSeasonStats < ActiveRecord::Migration[7.1]
  def change
    return unless table_exists?(:player_season_stats)

    return if index_name_exists?(:player_season_stats, :unique_player_season)
    
    remove_index :player_season_stats, column: [:nba_player_id, :season_id]

    add_index :player_season_stats,
              [:nba_player_id, :season_id],
              unique: true,
              name: :unique_player_season
  end
end
