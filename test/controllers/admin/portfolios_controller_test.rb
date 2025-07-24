require "test_helper"

class Admin::PortfoliosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_portfolios_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_portfolios_show_url
    assert_response :success
  end
end
