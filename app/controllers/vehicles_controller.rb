class VehiclesController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle, only: %i[show edit update destroy]

  def index
    @vehicles = current_user.vehicles
      .includes(:fuel_logs, reminders: :service_type)
      .order(:title)
  end

  def show
    active = @vehicle.active_reminders.to_a
    @overdue_reminders = active.select(&:overdue?)
    @approaching_reminders = active.reject(&:overdue?).select { |r| r.miles_remaining && r.miles_remaining <= 1000 }
    @ok_reminders = active.reject(&:overdue?).reject { |r| r.miles_remaining && r.miles_remaining <= 1000 }

    fuel_entries = @vehicle.fuel_logs.order(log_date: :desc).limit(5).map do |log|
      { type: :fuel, date: log.log_date, description: "#{log.gallons} gal @ #{ActionController::Base.helpers.number_to_currency(log.price_per_gallon)}", cost: log.total_cost }
    end
    service_entries = @vehicle.service_logs.includes(:service_type).order(log_date: :desc).limit(5).map do |log|
      { type: :service, date: log.log_date, description: log.service_type.name, cost: log.total_cost }
    end
    @recent_activity = (fuel_entries + service_entries).sort_by { |e| e[:date] || Date.new(2000) }.reverse.first(5)

    @last_service = @vehicle.service_logs.includes(:service_type).order(log_date: :desc).first
    @next_due = active.select(&:miles_remaining).min_by(&:miles_remaining)
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
    @vehicle = current_user.vehicles
      .includes(:fuel_logs, :service_logs, reminders: [:service_type, :reminder_type])
      .find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(
      :title, :make, :model, :year,
      :current_odometer, :oil_change_frequency, :tire_rotation_frequency
    )
  end
end
