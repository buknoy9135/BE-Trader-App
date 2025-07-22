require "test_helper"

class Trader::PortfolioControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trader_portfolio_index_url
    assert_response :success
  end
end
