# frozen_string_literal: true

# == Schema Information
#
# Table name: vehicles
#
#  id                      :integer          not null, primary key
#  current_odometer        :integer
#  make                    :string
#  model                   :string
#  oil_change_frequency    :integer
#  tire_rotation_frequency :integer
#  title                   :string
#  vin                     :string
#  year                    :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer          not null
#
# Indexes
#
#  index_vehicles_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class Vehicle < ApplicationRecord
  belongs_to :user
  has_many :fuel_logs, dependent: :destroy
  has_many :service_logs, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :budgets, dependent: :destroy

  validates :user_id, :title, presence: true
  validates :title, uniqueness: { scope: :user_id, message: 'must be unique per user' }

  def update_current_odometer!
    last_fuel_odometer = fuel_logs.maximum(:odometer).to_i
    last_service_odometer = service_logs.maximum(:odometer).to_i
    new_odometer = [last_fuel_odometer, last_service_odometer].max

    update_column(:current_odometer, new_odometer)
  end

  def fuel_total_cost
    fuel_logs.sum(:total_cost)
  end

  def miles_logged
    fuel_logs.sum(:miles)
  end

  def service_total_cost
    service_logs.sum(:total_cost)
  end

  def overall_mpg
    miles = miles_logged
    gallons = fuel_logs.sum(:gallons)
    return 0 if gallons.zero?

    (miles / gallons).round(1)
  end

  def most_recent_mpg
    fuel_logs.order(:log_date).last&.mpg
  end

  def previous_mpg
    fuel_logs.order(:log_date).offset(1).last&.mpg
  end

  def cost_per_mile
    miles = miles_logged
    return 0 if miles.zero?

    (fuel_total_cost / miles).round(3)
  end

  def average_cost_per_gallon
    gallons = fuel_logs.sum(:gallons)
    return 0 if gallons.zero?

    (fuel_total_cost / gallons).round(3)
  end

  def average_cost_per_fill_up
    fillups = fuel_logs.count
    return 0 if fillups.zero?

    (fuel_total_cost / fillups).round(2)
  end

  def best_mpg
    fuel_logs.maximum(:mpg)
  end

  def active_reminders
    reminders.where(completed_at: nil)
  end

  def display_name
    "#{year} #{make} #{model}".strip.presence || title
  end
end
