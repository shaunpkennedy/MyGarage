# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string
#  password_digest :string
#  username        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_username  (username) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(username: "testuser", email: "test@example.com", password: "password1", password_confirmation: "password1")
    assert user.valid?
  end

  test "requires username" do
    user = User.new(email: "test@example.com", password: "password1")
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "requires email" do
    user = User.new(username: "testuser", password: "password1")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires unique username" do
    user = User.new(username: users(:shaun).username, email: "unique@example.com", password: "password1")
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "requires password minimum 8 characters" do
    user = User.new(username: "newuser", email: "new@example.com", password: "short", password_confirmation: "short")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "authenticate with valid credentials" do
    result = User.authenticate("shaun", "password1")
    assert_equal users(:shaun), result
  end

  test "authenticate with invalid password returns false" do
    result = User.authenticate("shaun", "wrongpassword")
    assert_equal false, result
  end

  test "authenticate with unknown user returns nil" do
    result = User.authenticate("nobody", "password1")
    assert_nil result
  end

  test "destroys vehicles on delete" do
    user = users(:shaun)
    vehicle_count = user.vehicles.count
    assert vehicle_count > 0
    assert_difference("Vehicle.count", -vehicle_count) { user.destroy }
  end
end
