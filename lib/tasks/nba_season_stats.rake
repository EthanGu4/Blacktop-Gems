require "json"

namespace :nba do
  desc "Sync player season stats for a season_id (e.g. 2024-25) into player_season_stats"
  task :sync_season_stats, [ :season_id ] => :environment do |_, args|
    season_id = (args[:season_id] || Date.current.year.to_s).to_s
    season_id = season_id.strip
    raise "Provide season_id like 2024-25: rails nba:sync_season_stats[2024-25]" if season_id.empty?

    player_ids = ActiveNbaPlayer.where(is_active: true).pluck(:nba_player_id).compact
    raise "No active nba_player_id values found in ActiveNbaPlayer" if player_ids.empty?

    ids_path = Rails.root.join("tmp", "nba_player_ids.json")
    out_path = Rails.root.join("tmp", "season_stats.json")
    File.write(ids_path, JSON.dump(player_ids))

    py = Rails.root.join("scripts", "nba_fetch", "season_stats.py")
    cmd = [ "python", py.to_s, season_id, ids_path.to_s, out_path.to_s ]
    system(*cmd) or raise "Python fetch failed"

    rows = JSON.parse(File.read(out_path))

    upserts = rows.map do |r|
      {
        nba_player_id: r["nba_player_id"],
        season_id: r["season_id"],
        games_played: r["games_played"],
        total_minutes: r["total_minutes"],
        pts: r["pts"],
        reb: r["reb"],
        ast: r["ast"],
        stl: r["stl"],
        blk: r["blk"],
        tov: r["tov"],
        fg_pct: r["fg_pct"],
        fg3_pct: r["fg3_pct"],
        ft_pct: r["ft_pct"]
      }
    end

    ActiveRecord::Base.transaction do
      upserts.each_slice(1000) do |batch|
        PlayerSeasonStat.upsert_all(batch, unique_by: :unique_player_season)
      end
    end

    puts "✅ Upserted #{upserts.length} season rows for #{season_id}"
  end
end
