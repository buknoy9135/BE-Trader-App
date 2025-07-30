require "test_helper"

class Admin::FundsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_funds_index_url
    assert_response :success
  end
end
