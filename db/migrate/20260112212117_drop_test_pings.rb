class DropTestPings < ActiveRecord::Migration[8.1]
  def change
    drop_table :test_pings
  end
end
