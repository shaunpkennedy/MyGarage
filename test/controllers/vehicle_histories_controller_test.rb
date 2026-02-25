require "test_helper"

class VehicleHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:shaun))
    @vehicle = vehicles(:civic)
  end

  test "show history for own vehicle" do
    get vehicle_history_path(@vehicle)
    assert_response :success
  end

  test "history requires login" do
    delete logout_path
    get vehicle_history_path(@vehicle)
    assert_redirected_to login_path
  end

  test "cannot see history for other user vehicle" do
    get vehicle_history_path(vehicles(:jane_car))
    assert_response :not_found
  end
end
