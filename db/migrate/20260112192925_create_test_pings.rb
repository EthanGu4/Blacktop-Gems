class CreateTestPings < ActiveRecord::Migration[8.1]
  def change
    create_table :test_pings do |t|
      t.string :name

      t.timestamps
    end
  end
end
