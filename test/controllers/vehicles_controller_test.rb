require "test_helper"

class VehiclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:shaun))
    @vehicle = vehicles(:civic)
  end

  test "index shows user vehicles" do
    get vehicles_path
    assert_response :success
  end

  test "index requires login" do
    delete logout_path
    get vehicles_path
    assert_redirected_to login_path
  end

  test "show vehicle" do
    get vehicle_path(@vehicle)
    assert_response :success
  end

  test "cannot see other user vehicles" do
    get vehicle_path(vehicles(:jane_car))
    assert_response :not_found
  end

  test "new vehicle form" do
    get new_vehicle_path
    assert_response :success
  end

  test "create vehicle" do
    assert_difference("Vehicle.count", 1) do
      post vehicles_path, params: { vehicle: { title: "New Ride", make: "Tesla", model: "3", year: 2024 } }
    end
    assert_redirected_to vehicle_path(Vehicle.last)
  end

  test "update vehicle" do
    patch vehicle_path(@vehicle), params: { vehicle: { title: "Updated Title" } }
    assert_redirected_to vehicle_path(@vehicle)
    @vehicle.reload
    assert_equal "Updated Title", @vehicle.title
  end

  test "destroy vehicle" do
    assert_difference("Vehicle.count", -1) do
      delete vehicle_path(@vehicle)
    end
    assert_redirected_to vehicles_path
  end
end
