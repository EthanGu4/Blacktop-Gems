class ActiveNbaPlayer < ApplicationRecord
  self.table_name = "active_nba_players"

  has_many :season_stats,
           class_name: "PlayerSeasonStat",
           foreign_key: "nba_player_id",
           primary_key: "nba_player_id"

  def season_stat(season_id)
    season_stats.find_by(season_id: season_id)
  end

  scope :search, ->(q) {
    return all if q.blank?
    term = "%#{sanitize_sql_like(q)}%"
    where(
      "first_name ILIKE :t OR last_name ILIKE :t OR full_name ILIKE :t OR team_abbreviation ILIKE :t",
      t: term
    )
  }
end