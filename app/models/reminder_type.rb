# frozen_string_literal: true

# == Schema Information
#
# Table name: reminder_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ReminderType < ApplicationRecord
  has_many :reminders, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  DEFAULT_TYPES = [
    'By Mileage',
    'By Date',
    'By Both'
  ].freeze

  def self.seed_defaults!
    DEFAULT_TYPES.each do |name|
      find_or_create_by!(name: name)
    end
  end
end
