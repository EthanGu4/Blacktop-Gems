class ActiveNbaPlayer < ApplicationRecord
  self.table_name = "active_nba_players"

  scope :search, ->(q) {
    return all if q.blank?
    term = "%#{sanitize_sql_like(q)}%"
    where(
      "first_name ILIKE :t OR last_name ILIKE :t OR full_name ILIKE :t OR team_abbreviation ILIKE :t",
      t: term
    )
  }
end