class VehiclesController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle, only: %i[show edit update destroy]

  def index
    @vehicles = current_user.vehicles.order(:title)
  end

  def show
  end

  def new
    @vehicle = current_user.vehicles.build
  end

  def create
    @vehicle = current_user.vehicles.build(vehicle_params)

    if @vehicle.save
      flash[:notice] = 'Vehicle added successfully.'
      redirect_to @vehicle
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      flash[:notice] = 'Vehicle updated successfully.'
      redirect_to @vehicle
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.destroy
    flash[:notice] = 'Vehicle removed.'
    redirect_to vehicles_path
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(
      :title, :make, :model, :year,
      :current_odometer, :oil_change_frequency, :tire_rotation_frequency
    )
  end
end
