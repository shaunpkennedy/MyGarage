require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:shaun))
    @vehicle = vehicles(:civic)
  end

  test "show report for own vehicle" do
    get vehicle_report_path(@vehicle)
    assert_response :success
  end

  test "report requires login" do
    delete logout_path
    get vehicle_report_path(@vehicle)
    assert_redirected_to login_path
  end

  test "cannot see report for other user vehicle" do
    get vehicle_report_path(vehicles(:jane_car))
    assert_response :not_found
  end
end
