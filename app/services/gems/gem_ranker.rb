module Gems
  class GemRanker
    SEASON_ID = "2025-26"

    # ESPN-style constants (league-normalized)
    CONSTANTS = {
      fg:  2.209,
      ft:  1.405,
      fg3: 3.347,
      reb: 0.247,
      ast: 0.408,
      stl: 1.289,
      blk: 2.232,
      pts: 0.093
    }.freeze

    DEFAULT_WEIGHTS = {
      fg: 1, ft: 1, fg3: 1, reb: 1, ast: 1, stl: 1, blk: 1, pts: 1
    }.freeze

    def self.top_overall(limit: 16, season_id: SEASON_ID, weights: {})
      weights = normalize_weights(weights)
      c = weighted_constants(weights)

      sql = <<~SQL
        WITH season AS (
          SELECT
            s.nba_player_id,
            (
              ? * COALESCE(s.fg_pct, 0) +
              ? * COALESCE(s.ft_pct, 0) +
              ? * COALESCE(s.fg3_pct, 0) +
              ? * COALESCE(s.reb / s.games_played, 0) +
              ? * COALESCE(s.ast / s.games_played, 0) +
              ? * COALESCE(s.stl / s.games_played, 0) +
              ? * COALESCE(s.blk / s.games_played, 0) +
              ? * COALESCE(s.pts / s.games_played, 0)
            ) AS gem
          FROM player_season_stats s
          WHERE s.season_id = ?
        )
        SELECT
          p.*,
          season.gem AS gem_score
        FROM season
        JOIN active_nba_players p
          ON p.nba_player_id = season.nba_player_id
        ORDER BY season.gem DESC
        LIMIT ?
      SQL

      binds = [
        c[:fg], c[:ft], c[:fg3], c[:reb], c[:ast], c[:stl], c[:blk], c[:pts],
        season_id,
        limit
      ]

      ActiveNbaPlayer.find_by_sql([sql, *binds])
    end

    def self.hottest(limit: 16, season_id: SEASON_ID, weights: {}, recent_games: 5)
      weights = normalize_weights(weights)
      c = weighted_constants(weights)

      sql = <<~SQL
        WITH season AS (
          SELECT
            s.nba_player_id,
            (
              ? * COALESCE(s.fg_pct, 0) +
              ? * COALESCE(s.ft_pct, 0) +
              ? * COALESCE(s.fg3_pct, 0) +
              ? * COALESCE(s.reb / s.games_played, 0) +
              ? * COALESCE(s.ast / s.games_played, 0) +
              ? * COALESCE(s.stl / s.games_played, 0) +
              ? * COALESCE(s.blk / s.games_played, 0) +
              ? * COALESCE(s.pts / s.games_played, 0)
            ) AS season_gem
          FROM player_season_stats s
          WHERE s.season_id = ?
            AND s.games_played >= 20
        ),
        ranked_games AS (
          SELECT
            g.*,
            ROW_NUMBER() OVER (
              PARTITION BY g.nba_player_id
              ORDER BY g.game_date DESC
            ) AS rn
          FROM player_game_stats g
        ),
        recent AS (
          SELECT
            g.nba_player_id,
            AVG(
              ? * (CASE WHEN g.fg_attempted > 0 THEN g.fg_made::float / g.fg_attempted ELSE 0 END) +
              ? * (CASE WHEN g.ft_attempted > 0 THEN g.ft_made::float / g.ft_attempted ELSE 0 END) +
              ? * (CASE WHEN g.fg3_attempted > 0 THEN g.fg3_made::float / g.fg3_attempted ELSE 0 END) +
              ? * COALESCE(g.reb, 0) +
              ? * COALESCE(g.ast, 0) +
              ? * COALESCE(g.stl, 0) +
              ? * COALESCE(g.blk, 0) +
              ? * COALESCE(g.pts, 0)
            ) AS recent_gem
          FROM ranked_games g
          WHERE g.rn <= ?
          GROUP BY g.nba_player_id
        ),
        deltas AS (
          SELECT
            season.nba_player_id,
            season.season_gem,
            recent.recent_gem,
            (recent.recent_gem - season.season_gem) AS delta
          FROM season
          JOIN recent ON recent.nba_player_id = season.nba_player_id
        ),
        scored AS (
          SELECT
            *,
            AVG(delta) OVER () AS mean_delta,
            STDDEV_SAMP(delta) OVER () AS std_delta
          FROM deltas
        )
        SELECT
          p.*,
          season_gem,
          recent_gem,
          delta,
          CASE
            WHEN std_delta IS NULL OR std_delta = 0 THEN NULL
            ELSE (delta - mean_delta) / std_delta
          END AS z_score
        FROM scored
        JOIN active_nba_players p
          ON p.nba_player_id = scored.nba_player_id
        ORDER BY z_score DESC NULLS LAST
        LIMIT ?
      SQL

      binds = [
        c[:fg], c[:ft], c[:fg3], c[:reb], c[:ast], c[:stl], c[:blk], c[:pts],
        season_id,
        c[:fg], c[:ft], c[:fg3], c[:reb], c[:ast], c[:stl], c[:blk], c[:pts],
        recent_games,
        limit
      ]

      ActiveNbaPlayer.find_by_sql([sql, *binds])
    end

    def self.normalize_weights(weights)
      w = DEFAULT_WEIGHTS.merge(symbolize_keys(weights))
      sum = w.values.map(&:to_f).sum
      w.transform_values { |v| v.to_f / sum }
    end

    def self.weighted_constants(weights)
      CONSTANTS.transform_values { |v| v }.merge(
        fg:  CONSTANTS[:fg]  * weights[:fg],
        ft:  CONSTANTS[:ft]  * weights[:ft],
        fg3: CONSTANTS[:fg3] * weights[:fg3],
        reb: CONSTANTS[:reb] * weights[:reb],
        ast: CONSTANTS[:ast] * weights[:ast],
        stl: CONSTANTS[:stl] * weights[:stl],
        blk: CONSTANTS[:blk] * weights[:blk],
        pts: CONSTANTS[:pts] * weights[:pts]
      )
    end

    def self.symbolize_keys(hash)
      (hash || {}).transform_keys { |k| k.to_s.downcase.to_sym }
    end
  end
end
