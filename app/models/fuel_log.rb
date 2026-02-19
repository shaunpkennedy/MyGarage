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

  after_save :update_vehicle_odometer

  private

  def update_vehicle_odometer
    vehicle.update_current_odometer!
  end
end
