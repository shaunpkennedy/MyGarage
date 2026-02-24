require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "get login page" do
    get login_path
    assert_response :success
  end

  test "login with valid credentials" do
    post login_path, params: { username: "shaun", password: "password1" }
    assert_redirected_to vehicles_path
    assert_equal users(:shaun).id, session[:user_id]
  end

  test "login with invalid credentials" do
    post login_path, params: { username: "shaun", password: "wrong" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "logout clears session" do
    log_in_as(users(:shaun))
    delete logout_path
    assert_redirected_to login_path
    assert_nil session[:user_id]
  end
end
