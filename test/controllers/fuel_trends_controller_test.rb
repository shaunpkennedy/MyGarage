require "test_helper"

class FuelTrendsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:shaun))
    @vehicle = vehicles(:civic)
  end

  test "show fuel trends page" do
    get vehicle_fuel_trend_path(@vehicle)
    assert_response :success
  end

  test "show fuel trends with no fuel logs" do
    truck = vehicles(:truck)
    get vehicle_fuel_trend_path(truck)
    assert_response :success
  end

  test "rejects unauthenticated access" do
    delete logout_path
    get vehicle_fuel_trend_path(@vehicle)
    assert_redirected_to login_path
  end
end
