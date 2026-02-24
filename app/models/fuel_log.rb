# frozen_string_literal: true

# == Schema Information
#
# Table name: fuel_logs
#
#  id               :integer          not null, primary key
#  gallons          :decimal(6, 3)
#  log_date         :datetime
#  miles            :integer
#  mpg              :decimal(4, 1)
#  odometer         :integer
#  price_per_gallon :decimal(6, 3)
#  total_cost       :decimal(7, 2)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  vehicle_id       :integer          not null
#
# Indexes
#
#  index_fuel_logs_on_vehicle_id  (vehicle_id)
#
# Foreign Keys
#
#  vehicle_id  (vehicle_id => vehicles.id)
#
class FuelLog < ApplicationRecord
  belongs_to :vehicle

  validates :vehicle_id, :odometer, :gallons, presence: true

  before_save :calculate_miles_and_mpg
  after_save :update_vehicle_odometer

  private

  def calculate_miles_and_mpg
    previous_log = vehicle.fuel_logs
      .where.not(id: id)
      .where("odometer < ?", odometer)
      .order(odometer: :desc)
      .first

    if previous_log
      self.miles = odometer - previous_log.odometer
      self.mpg = (miles.to_f / gallons).round(1) if gallons&.positive?
    end

    self.total_cost = (price_per_gallon * gallons).round(2) if price_per_gallon&.positive? && gallons&.positive? && total_cost.blank?
  end

  def update_vehicle_odometer
    vehicle.update_current_odometer!
  end
end
