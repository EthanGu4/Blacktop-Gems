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
  end
end
