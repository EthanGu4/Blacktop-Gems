require "json"
require "set"

namespace :nba do
  desc "Sync active NBA players into players table (upsert by nba_player_id)"
  task sync_active_players: :environment do
    py = Rails.root.join("scripts", "nba_fetch", "active_players.py")
    output = `python "#{py}"`
    raise "Python fetch failed" unless $?.success?

    rows = JSON.parse(output)

    now = Time.current
    active_ids = Set.new(rows.map { |r| r["id"] })

    upserts = rows.map do |p|
      {
        nba_player_id: p["id"],
        first_name: p["first_name"],
        last_name: p["last_name"],
        full_name: p["full_name"],
        is_active: true,
      }
    end

    ActiveRecord::Base.transaction do
      upserts.each_slice(1000) do |batch|
        ActiveNbaPlayer.upsert_all(batch, unique_by: :nba_player_id)
      end

      ActiveNbaPlayer.where.not(nba_player_id: active_ids.to_a).update_all(is_active: false)
    end

    puts "✅ Upserted #{rows.length} active players"
    puts "✅ Marked inactive everyone else"
  end
end
