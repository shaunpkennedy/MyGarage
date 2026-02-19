# frozen_string_literal: true

# == Schema Information
#
# Table name: service_logs
#
#  id              :integer          not null, primary key
#  log_date        :datetime
#  notes           :text
#  odometer        :integer
#  total_cost      :decimal(7, 2)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  service_type_id :integer          not null
#  vehicle_id      :integer          not null
#
# Indexes
#
#  index_service_logs_on_service_type_id  (service_type_id)
#  index_service_logs_on_vehicle_id       (vehicle_id)
#
# Foreign Keys
#
#  service_type_id  (service_type_id => service_types.id)
#  vehicle_id       (vehicle_id => vehicles.id)
#
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
