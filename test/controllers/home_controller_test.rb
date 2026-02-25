require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "landing page renders for unauthenticated user" do
    get root_path
    assert_response :success
    assert_select "h1", "My Garage"
  end

  test "dashboard renders for logged-in user" do
    log_in_as(users(:shaun))
    get root_path
    assert_response :success
    assert_select "h2", "Dashboard"
  end

  test "dashboard shows vehicle cards" do
    log_in_as(users(:shaun))
    get root_path
    assert_select ".vehicle-card", minimum: 1
  end

  test "dashboard redirects to login for unauthenticated user trying dashboard" do
    get root_path
    assert_response :success
    assert_select "h2", { count: 0, text: "Dashboard" }
  end
end
