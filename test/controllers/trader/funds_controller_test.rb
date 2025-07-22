require "test_helper"

class Trader::FundsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trader_funds_index_url
    assert_response :success
  end

  test "should get new" do
    get trader_funds_new_url
    assert_response :success
  end

  test "should get create" do
    get trader_funds_create_url
    assert_response :success
  end
end
