require "test_helper"

class ServiceLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:shaun))
    @vehicle = vehicles(:civic)
    @service_log = service_logs(:oil_change_one)
  end

  test "index shows service logs" do
    get vehicle_service_logs_path(@vehicle)
    assert_response :success
  end

  test "export service logs as csv" do
    get export_vehicle_service_logs_path(@vehicle)
    assert_response :success
    assert_equal "text/csv", response.content_type
    assert_includes response.body, "date,odometer,service_type"
  end

  test "import service logs from csv" do
    csv_content = "date,odometer,service_type,total_cost,notes\n2025-03-15,52500,Oil Change,49.99,Full synthetic\n"
    file = Rack::Test::UploadedFile.new(
      StringIO.new(csv_content), "text/csv", original_filename: "services.csv"
    )

    assert_difference("ServiceLog.count", 1) do
      post import_vehicle_service_logs_path(@vehicle), params: { file: file }
    end
    assert_redirected_to vehicle_service_logs_path(@vehicle)
  end

  test "import skips rows with unknown service type" do
    csv_content = "date,odometer,service_type,total_cost,notes\n2025-03-15,52500,Unknown Service,49.99,Test\n"
    file = Rack::Test::UploadedFile.new(
      StringIO.new(csv_content), "text/csv", original_filename: "services.csv"
    )

    assert_no_difference("ServiceLog.count") do
      post import_vehicle_service_logs_path(@vehicle), params: { file: file }
    end
  end

  test "import without file shows error" do
    post import_vehicle_service_logs_path(@vehicle)
    assert_redirected_to vehicle_service_logs_path(@vehicle)
    assert_equal "Please select a CSV file.", flash[:alert]
  end
end
