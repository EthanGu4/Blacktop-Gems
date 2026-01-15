class AddBalldontlieIdToActivePlayers < ActiveRecord::Migration[7.1]
  def change
    add_column :active_players, :balldontlie_player_id, :integer

    add_index :active_players,
              :balldontlie_player_id,
              unique: true,
              where: "balldontlie_player_id IS NOT NULL"
  end
end