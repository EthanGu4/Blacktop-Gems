class PlayerSeasonStat < ApplicationRecord
  self.table_name = "player_season_stats"

  belongs_to :player,
            class_name: "ActiveNbaPlayer",
            foreign_key: "nba_player_id",
            primary_key: "nba_player_id",
            optional: true
end