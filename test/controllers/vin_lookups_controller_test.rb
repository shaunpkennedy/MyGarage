require "test_helper"

class VinLookupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:shaun))
  end

  test "rejects unauthenticated access" do
    delete logout_path
    get vin_lookup_path, params: { vin: "1HGBH41JXMN109186" }
    assert_redirected_to login_path
  end

  test "rejects blank VIN" do
    get vin_lookup_path, params: { vin: "" }
    assert_response :unprocessable_entity
  end

  test "rejects VIN with wrong length" do
    get vin_lookup_path, params: { vin: "SHORT" }
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "VIN must be exactly 17 characters", json["error"]
  end
end
