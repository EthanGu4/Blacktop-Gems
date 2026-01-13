module Api
  class PlayersController < ApplicationController
    def active
        render json: Balldontlie::Client.active_players_all(per_page: 100)
    end

    def search
      query = params[:q].to_s.strip

      if query.blank?
        render json: { error: "Missing search query (?q=...)" }, status: 400
        return
      end

      payload = Balldontlie::Client.http_get_with_retry(
        URI("https://api.balldontlie.io/v1/players?search=#{CGI.escape(query)}")
      )

      results = (payload["data"] || []).map do |player|
        {
          id: player["id"],
          first_name: player["first_name"],
          last_name: player["last_name"],
          team: player.dig("team", "abbreviation")
        }
      end

      render json: results
    end
  end
end