require "json"

namespace :nba do
  desc "Fetch + upsert last 10 games for all active players into player_game_stats"
  task :sync_last10_games, [:season_id, :days_back] => :environment do |_, args|
    season_id = (args[:season_id] || "2025-26").to_s.strip
    days_back = (args[:days_back] || "50").to_s.strip.to_i

    active_ids = ActiveNbaPlayer.where(is_active: true).pluck(:nba_player_id).compact
    raise "No active nba_player_id found in active_nba_players" if active_ids.empty?

    ids_path = Rails.root.join("tmp", "active_player_ids.json")
    out_path = Rails.root.join("tmp", "last10_game_logs.json")
    File.write(ids_path, JSON.dump(active_ids))

    py = Rails.root.join("scripts", "nba_fetch", "last_ten_games.py")
    cmd = ["python", py.to_s, season_id, days_back.to_s, ids_path.to_s, out_path.to_s]
    puts "Running: #{cmd.join(' ')}"
    system(*cmd) or raise "Python fetch failed"

    rows = JSON.parse(File.read(out_path))
    puts "Python returned #{rows.length} rows"

    now = Time.current
    upserts = rows.map do |r|
      {
        game_id: r["game_id"],
        nba_player_id: r["nba_player_id"],
        game_date: r["game_date"],

        minutes: r["minutes"],
        pts: r["pts"],
        reb: r["reb"],
        ast: r["ast"],
        stl: r["stl"],
        blk: r["blk"],
        tov: r["tov"],

        fg_made: r["fg_made"],
        fg_attempted: r["fg_attempted"],
        fg3_made: r["fg3_made"],
        fg3_attempted: r["fg3_attempted"],
        ft_made: r["ft_made"],
        ft_attempted: r["ft_attempted"],

        plus_minus: r["plus_minus"],
      }
    end

    ActiveRecord::Base.transaction do
      upserts.each_slice(1000) do |batch|
        PlayerGameStat.upsert_all(batch, unique_by: :unique_game_player)
      end
    end

    puts "✅ Upserted #{upserts.length} player-game rows for season #{season_id} (days_back=#{days_back})"
  end
end
