class FuelLogsController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle
  before_action :set_fuel_log, only: %i[show edit update destroy]

  def index
    @fuel_logs = @vehicle.fuel_logs.order(log_date: :desc)
    @fuel_logs = @fuel_logs.where("log_date >= ?", params[:from]) if params[:from].present?
    @fuel_logs = @fuel_logs.where("log_date <= ?", params[:to]) if params[:to].present?
  end

  def show
  end

  def new
    @fuel_log = @vehicle.fuel_logs.build(
      log_date: Date.current,
      odometer: @vehicle.current_odometer
    )
  end

  def create
    @fuel_log = @vehicle.fuel_logs.build(fuel_log_params)

    if @fuel_log.save
      flash[:notice] = 'Fill-up recorded.'
      redirect_to vehicle_path(@vehicle)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @fuel_log.update(fuel_log_params)
      flash[:notice] = 'Fill-up updated.'
      redirect_to vehicle_path(@vehicle)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fuel_log.destroy
    flash[:notice] = 'Fill-up removed.'
    redirect_to vehicle_fuel_logs_path(@vehicle)
  end

  def export
    fuel_logs = @vehicle.fuel_logs.order(:log_date)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[date odometer gallons price_per_gallon total_cost miles mpg]
      fuel_logs.each do |log|
        csv << [
          log.log_date&.strftime("%Y-%m-%d"),
          log.odometer,
          log.gallons,
          log.price_per_gallon,
          log.total_cost,
          log.miles,
          log.mpg
        ]
      end
    end

    send_data csv_data,
      filename: "#{@vehicle.title.parameterize}-fuel-logs.csv",
      type: "text/csv"
  end

  def import
    file = params[:file]

    if file.blank?
      flash[:alert] = "Please select a CSV file."
      redirect_to vehicle_fuel_logs_path(@vehicle) and return
    end

    imported = 0
    skipped = 0

    CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
      fuel_log = @vehicle.fuel_logs.build(
        log_date: row[:date],
        odometer: row[:odometer],
        gallons: row[:gallons],
        price_per_gallon: row[:price_per_gallon],
        total_cost: row[:total_cost]
      )

      if fuel_log.save
        imported += 1
      else
        skipped += 1
      end
    end

    flash[:notice] = "Imported #{imported} fill-up#{'s' unless imported == 1}."
    flash[:alert] = "Skipped #{skipped} invalid row#{'s' unless skipped == 1}." if skipped > 0
    redirect_to vehicle_fuel_logs_path(@vehicle)
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:vehicle_id])
  end

  def set_fuel_log
    @fuel_log = @vehicle.fuel_logs.find(params[:id])
  end

  def fuel_log_params
    params.require(:fuel_log).permit(
      :log_date, :odometer, :price_per_gallon, :gallons, :total_cost
    )
  end
end
