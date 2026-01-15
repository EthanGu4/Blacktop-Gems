class CreatePlayerGameStats < ActiveRecord::Migration[7.1]
  def change
    return if table_exists?(:player_game_stats)
    create_table :player_game_stats do |t|
      t.string  :game_id, null: false
      t.integer :nba_player_id, null: false
      t.date    :game_date, null: false

      t.string  :minutes
      t.float   :pts
      t.float   :reb
      t.float   :ast
      t.float   :stl
      t.float   :blk
      t.integer :tov
      t.integer :fg_made
      t.integer :fg_attempted
      t.integer :fg3_made
      t.integer :fg3_attempted
      t.integer :ft_made
      t.integer :ft_attempted
      t.integer :plus_minus
    end

    add_index :player_game_stats, [:nba_player_id, :game_id], unique: true
    add_index :player_game_stats, :game_date
  end
end
