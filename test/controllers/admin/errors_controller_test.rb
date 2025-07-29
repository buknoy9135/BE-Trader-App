require "test_helper"

class Admin::ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get not_found" do
    get admin_errors_not_found_url
    assert_response :success
  end
end
