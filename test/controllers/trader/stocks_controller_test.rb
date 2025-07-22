require "test_helper"

class Trader::StocksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trader_stocks_index_url
    assert_response :success
  end

  test "should get show" do
    get trader_stocks_show_url
    assert_response :success
  end
end
