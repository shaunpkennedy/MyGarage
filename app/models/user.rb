# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :vehicles, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def self.authenticate(username, password)
    user = find_by(username: username)
    user&.authenticate(password)
  end
end