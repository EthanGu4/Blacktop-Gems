# lib/tasks/balldontlie.rake
namespace :balldontlie do
  desc "One-time sync: attach balldontlie_player_id to active_players"
  task sync_active_player_ids: :environment do
    whitelist = ActivePlayer.all.index_by do |p|
      [ p.first_name.strip, p.last_name.strip, p.team_abbr.strip ]
    end

    puts "Loaded #{whitelist.size} local active players"

    cursor = nil
    synced = 0

    loop do
      payload = Balldontlie::Client.list_players_page(
        endpoint: "/players",
        per_page: 100,
        cursor: cursor
      )

      players = payload["data"] || []
      meta    = payload["meta"] || {}

      players.each do |player|
        key = [
          player["first_name"].to_s.strip,
          player["last_name"].to_s.strip,
          player.dig("team", "abbreviation").to_s.strip
        ]

        local = whitelist[key]
        next unless local

        local.update!(
          balldontlie_player_id: player["id"]
        )

        synced += 1
      end

      cursor = meta["next_cursor"]
      break if cursor.nil?

      sleep 13
    end

    puts "✅ Synced #{synced} players"
  end
end
