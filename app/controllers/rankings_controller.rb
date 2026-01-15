class RankingsController < ApplicationController
  def index
    @weights = {
      fg:  params.fetch(:fg,  1),
      ft:  params.fetch(:ft,  1),
      fg3: params.fetch(:fg3, 1),
      reb: params.fetch(:reb, 1),
      ast: params.fetch(:ast, 1),
      stl: params.fetch(:stl, 1),
      blk: params.fetch(:blk, 1),
      pts: params.fetch(:pts, 1)
    }

    @top_players = Gems::GemRanker.top_overall(limit: 16, weights: @weights)

    @hot_players = Gems::GemRanker.hottest(
      limit: 16,
      weights: @weights,
      recent_games: 5
    )
  end
end
