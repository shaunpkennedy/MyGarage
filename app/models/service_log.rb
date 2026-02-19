# frozen_string_literal: true

class ServiceLog < ApplicationRecord
  belongs_to :vehicle
  belongs_to :service_type

  validates :vehicle_id, :odometer, :service_type_id, presence: true

  after_save :update_vehicle_odometer

  private

  def update_vehicle_odometer
    vehicle.update_current_odometer!
  end
end