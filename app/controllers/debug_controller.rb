class DebugController < ApplicationController
  def jokic
    py = Rails.root.join("scripts", "nba_fetch", "career.py")

    output = `python "#{py}"`

    render json: JSON.parse(output)
  rescue => e
    render json: { error: e.message }, status: 500
  end
end
