require "test_helper"

class Trader::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trader_dashboard_index_url
    assert_response :success
  end
end
