require "test_helper"

class Trader::TransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trader_transactions_index_url
    assert_response :success
  end
end
