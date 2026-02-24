class ServiceLogsController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle
  before_action :set_service_log, only: %i[show edit update destroy]

  def index
    @service_logs = @vehicle.service_logs.includes(:service_type).order(log_date: :desc)
  end

  def show
  end

  def new
    @service_log = @vehicle.service_logs.build(
      log_date: Date.current,
      odometer: @vehicle.current_odometer
    )
  end

  def create
    @service_log = @vehicle.service_logs.build(service_log_params)

    if @service_log.save
      flash[:notice] = 'Service record saved.'
      redirect_to vehicle_path(@vehicle)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service_log.update(service_log_params)
      flash[:notice] = 'Service record updated.'
      redirect_to vehicle_path(@vehicle)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service_log.destroy
    flash[:notice] = 'Service record removed.'
    redirect_to vehicle_service_logs_path(@vehicle)
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:vehicle_id])
  end

  def set_service_log
    @service_log = @vehicle.service_logs.find(params[:id])
  end

  def service_log_params
    params.require(:service_log).permit(:log_date, :odometer, :service_type_id, :total_cost, :notes)
  end
end
