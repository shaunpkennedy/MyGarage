require "test_helper"

class FuelLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:shaun))
    @vehicle = vehicles(:civic)
    @fuel_log = fuel_logs(:first_fill)
  end

  test "index shows fuel logs" do
    get vehicle_fuel_logs_path(@vehicle)
    assert_response :success
  end

  test "index with date filter" do
    get vehicle_fuel_logs_path(@vehicle), params: { from: "2025-01-10", to: "2025-01-20" }
    assert_response :success
  end

  test "new fuel log form" do
    get new_vehicle_fuel_log_path(@vehicle)
    assert_response :success
  end

  test "create fuel log" do
    assert_difference("FuelLog.count", 1) do
      post vehicle_fuel_logs_path(@vehicle), params: {
        fuel_log: { log_date: Date.current, odometer: 51000, gallons: 12.0, price_per_gallon: 3.50 }
      }
    end
    assert_redirected_to vehicle_path(@vehicle)
  end

  test "destroy fuel log" do
    assert_difference("FuelLog.count", -1) do
      delete vehicle_fuel_log_path(@vehicle, @fuel_log)
    end
    assert_redirected_to vehicle_fuel_logs_path(@vehicle)
  end
end
