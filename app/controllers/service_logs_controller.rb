class ServiceLogsController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle
  before_action :set_service_log, only: %i[show edit update destroy]

  def index
    @service_logs = @vehicle.service_logs.includes(:service_type).order(log_date: :desc)
    @service_logs = @service_logs.where("log_date >= ?", params[:from]) if params[:from].present?
    @service_logs = @service_logs.where("log_date <= ?", params[:to]) if params[:to].present?
    @service_logs = @service_logs.where(service_type_id: params[:service_type_id]) if params[:service_type_id].present?
    @service_logs = @service_logs.where("total_cost >= ?", params[:cost_min]) if params[:cost_min].present?
    @service_logs = @service_logs.where("total_cost <= ?", params[:cost_max]) if params[:cost_max].present?
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

  def export
    service_logs = @vehicle.service_logs.includes(:service_type).order(:log_date)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[date odometer service_type total_cost notes]
      service_logs.each do |log|
        csv << [
          log.log_date&.strftime("%Y-%m-%d"),
          log.odometer,
          log.service_type.name,
          log.total_cost,
          log.notes
        ]
      end
    end

    send_data csv_data,
      filename: "#{@vehicle.title.parameterize}-service-logs.csv",
      type: "text/csv"
  end

  def import
    file = params[:file]

    if file.blank?
      flash[:alert] = "Please select a CSV file."
      redirect_to vehicle_service_logs_path(@vehicle) and return
    end

    imported = 0
    skipped = 0

    CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
      service_type = ServiceType.where("LOWER(name) = ?", row[:service_type].to_s.strip.downcase).first

      unless service_type
        skipped += 1
        next
      end

      service_log = @vehicle.service_logs.build(
        log_date: row[:date],
        odometer: row[:odometer],
        service_type: service_type,
        total_cost: row[:total_cost],
        notes: row[:notes]
      )

      if service_log.save
        imported += 1
      else
        skipped += 1
      end
    end

    flash[:notice] = "Imported #{imported} service record#{'s' unless imported == 1}."
    flash[:alert] = "Skipped #{skipped} invalid row#{'s' unless skipped == 1}." if skipped > 0
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
