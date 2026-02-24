ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    fixtures :all
  end
end

module ActionDispatch
  class IntegrationTest
    def log_in_as(user, password: "password1")
      post login_path, params: { username: user.username, password: password }
    end
  end
end
