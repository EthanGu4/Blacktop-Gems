class ActivePlayer < ApplicationRecord
  validates :balldontlie_player_id, uniqueness: true, allow_nil: true
end