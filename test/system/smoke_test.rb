require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  test "home loads" do
    visit root_path
    assert_text "Blacktop Gems"
  end
end
