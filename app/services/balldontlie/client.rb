require "net/http"
require "json"
require "uri"
require "set"

module Balldontlie
  class Client
    BASE_URL = "https://api.balldontlie.io/v1"

    # Public: returns ALL matches across all pages (cursor pagination),
    # defaulting to /players/active to reduce requests.
    def self.active_players_all(per_page: 100, endpoint: "/players/active", max_pages: 50)
      whitelist = active_player_whitelist_set

      cursor = nil
      page_count = 0
      all_matches = []

      loop do
        page_count += 1
        break if max_pages && page_count > max_pages

        payload = list_players_page(endpoint: endpoint, per_page: per_page, cursor: cursor)

        players = payload["data"] || []
        meta    = payload["meta"] || {}

        matches = players.select do |player|
          first = player["first_name"].to_s.strip
          last  = player["last_name"].to_s.strip
          abbr  = player.dig("team", "abbreviation").to_s.strip
          next false if first.empty? || last.empty? || abbr.empty?
          whitelist.include?([first, last, abbr])
        end

        all_matches.concat(matches)

        cursor = meta["next_cursor"]
        break if cursor.nil?

        # Tiny delay to be nice to the API (helps reduce 429s)
        sleep 0.15
      end

      {
        data: all_matches,
        meta: {
          definition: "matches active_players table (first_name, last_name, team_abbr)",
          returned: all_matches.length,
          per_page: per_page,
          endpoint: endpoint,
          pages_fetched: page_count
        }
      }
    end

    # Fetch ONE cursor page, with caching.
    def self.list_players_page(endpoint:, per_page:, cursor:)
      uri = URI("#{BASE_URL}#{endpoint}")
      params = { per_page: per_page }
      params[:cursor] = cursor unless cursor.nil?
      uri.query = URI.encode_www_form(params)

      Rails.logger.info("BALLDONTLIE request URL => #{uri}")

      cache_key = "balldontlie:v1:#{endpoint}:per#{per_page}:cursor#{cursor || 'nil'}"
      Rails.cache.fetch(cache_key, expires_in: 6.hours) do
        http_get_with_retry(uri)
      end
    end

    # Your whitelist method (unchanged)
    def self.active_player_whitelist_set
      Set.new(
        ActivePlayer.pluck(:first_name, :last_name, :team_abbr).map do |f, l, t|
          [f.to_s.strip, l.to_s.strip, t.to_s.strip]
        end
      )
    end

    # HTTP with 429 handling (Retry-After + exponential backoff)
    def self.http_get_with_retry(uri, max_retries: 6)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = ENV["BALLDONTLIE_API_KEY"]

      attempt = 0

      begin
        attempt += 1
        res = http.request(request)

        if res.code.to_i == 429
          retry_after = res["Retry-After"].to_i
          wait = retry_after.positive? ? retry_after : (2 ** [attempt, 6].min)
          Rails.logger.warn("BALLDONTLIE 429 rate-limited. Waiting #{wait}s (attempt #{attempt}/#{max_retries})")
          sleep(wait)
          raise "retry_429"
        end

        unless res.is_a?(Net::HTTPSuccess)
          raise "BALLDONTLIE error: #{res.code} #{res.body}"
        end

        JSON.parse(res.body)
      rescue => e
        if e.message == "retry_429" && attempt < max_retries
          retry
        end

        # also retry on transient network errors
        if attempt < max_retries && (e.is_a?(Timeout::Error) || e.is_a?(Errno::ECONNRESET) || e.is_a?(SocketError))
          sleep(2 ** [attempt, 6].min)
          retry
        end

        raise
      end
    end
  end
end
