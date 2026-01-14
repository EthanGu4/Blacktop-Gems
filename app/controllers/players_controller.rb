class PlayersController < ApplicationController
  def index
    @q = params[:q]
    @players = ActiveNbaPlayer
      .search(@q)
      .order(:last_name, :first_name)
      .limit(1000)
  end

  def show
    @player = ActiveNbaPlayer.find(params[:id])
    @stats = @player.season_stats.find_by(season_id: "2025-26")
  end
end
