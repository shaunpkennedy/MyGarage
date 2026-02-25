class VehicleHistoriesController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle

  def show
    @service_logs = @vehicle.service_logs.includes(:service_type).order(:log_date)
    @fuel_logs = @vehicle.fuel_logs.order(:log_date)
    @total_spent = @vehicle.fuel_total_cost + @vehicle.service_total_cost
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles
      .includes(:fuel_logs, service_logs: :service_type)
      .find(params[:vehicle_id])
  end
end
