# frozen_string_literal: true

class FuelLog < ApplicationRecord
  belongs_to :vehicle

  validates :vehicle_id, :odometer, :gallons, presence: true

  after_save :update_vehicle_odometer

  private

  def update_vehicle_odometer
    vehicle.update_current_odometer!
  end
end