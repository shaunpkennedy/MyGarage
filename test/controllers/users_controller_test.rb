require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "get signup page" do
    get signup_path
    assert_response :success
  end

  test "create user with valid params" do
    assert_difference("User.count", 1) do
      post signup_path, params: { user: { username: "newuser", email: "new@example.com", password: "password1", password_confirmation: "password1" } }
    end
    assert_redirected_to vehicles_path
    assert session[:user_id]
  end

  test "create user with invalid params re-renders form" do
    assert_no_difference("User.count") do
      post signup_path, params: { user: { username: "", email: "", password: "short" } }
    end
    assert_response :unprocessable_entity
  end

  test "edit profile requires login" do
    get edit_profile_path
    assert_redirected_to login_path
  end

  test "edit profile when logged in" do
    log_in_as(users(:shaun))
    get edit_profile_path
    assert_response :success
  end
end
