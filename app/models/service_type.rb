# frozen_string_literal: true

# == Schema Information
#
# Table name: service_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ServiceType < ApplicationRecord
  has_many :service_logs, dependent: :restrict_with_error
  has_many :reminders, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  DEFAULT_TYPES = [
    'Oil Change',
    'Tire Rotation',
    'New Tires',
    'Brake Pads',
    'Brake Rotors',
    'Air Filter',
    'Cabin Filter',
    'Spark Plugs',
    'Transmission Fluid',
    'Coolant Flush',
    'Battery',
    'Wiper Blades',
    'Alignment',
    'Inspection',
    'Other'
  ].freeze

  def self.seed_defaults!
    DEFAULT_TYPES.each do |name|
      find_or_create_by!(name: name)
    end
  end
end
