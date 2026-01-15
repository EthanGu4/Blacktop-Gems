class NameUniqueIndexForPlayerGameStats < ActiveRecord::Migration[7.1]
  def change
    return unless table_exists?(:player_game_stats)

    return if index_name_exists?(:player_game_stats, :unique_game_player)
    
    remove_index :player_game_stats, column: [:nba_player_id, :game_id]

    add_index :player_game_stats,
              [:nba_player_id, :game_id],
              unique: true,
              name: :unique_game_player
  end
end
