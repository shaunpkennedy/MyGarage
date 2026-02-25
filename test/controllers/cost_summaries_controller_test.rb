require "test_helper"

class CostSummariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:shaun))
    @vehicle = vehicles(:civic)
  end

  test "show cost summary with default monthly view" do
    get vehicle_cost_summary_path(@vehicle)
    assert_response :success
    assert_select "h2", "Cost Summary"
    assert_select "table"
  end

  test "show cost summary with yearly view" do
    get vehicle_cost_summary_path(@vehicle, view: :yearly)
    assert_response :success
    assert_select "table"
  end

  test "cost summary requires login" do
    delete logout_path
    get vehicle_cost_summary_path(@vehicle)
    assert_redirected_to login_path
  end

  test "cannot see cost summary for other user vehicle" do
    get vehicle_cost_summary_path(vehicles(:jane_car))
    assert_response :not_found
  end
end
