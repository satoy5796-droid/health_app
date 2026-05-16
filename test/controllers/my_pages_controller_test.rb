require "test_helper"

class MyPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get advice_history" do
    get my_pages_advice_history_url
    assert_response :success
  end
end
