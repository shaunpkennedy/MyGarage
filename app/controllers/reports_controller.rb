class ReportsController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle

  def show
    @fuel_logs = @vehicle.fuel_logs.order(:log_date)
    @service_logs = @vehicle.service_logs.includes(:service_type).order(:log_date)

    prepare_mpg_over_time
    prepare_fuel_spending_by_month
    prepare_service_spending_by_category
    prepare_monthly_cost_summary
    prepare_fuel_price_trend
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles
      .includes(:fuel_logs, service_logs: :service_type)
      .find(params[:vehicle_id])
  end

  def prepare_mpg_over_time
    logs_with_mpg = @fuel_logs.select { |l| l.mpg.present? }
    @mpg_labels = logs_with_mpg.map { |l| l.log_date&.strftime("%b %d, %Y") }
    @mpg_data = logs_with_mpg.map(&:mpg)
  end

  def prepare_fuel_spending_by_month
    grouped = @fuel_logs
      .select { |l| l.total_cost.present? }
      .group_by { |l| l.log_date&.strftime("%Y-%m") }
    @fuel_monthly_labels = grouped.keys.compact.sort
    @fuel_monthly_data = @fuel_monthly_labels.map { |m| grouped[m].sum { |l| l.total_cost.to_f }.round(2) }
    @fuel_monthly_labels = @fuel_monthly_labels.map { |m| Date.strptime(m, "%Y-%m").strftime("%b %Y") }
  end

  def prepare_service_spending_by_category
    grouped = @service_logs
      .select { |l| l.total_cost.present? }
      .group_by { |l| l.service_type.name }
    @service_category_labels = grouped.keys.sort
    @service_category_data = @service_category_labels.map { |c| grouped[c].sum { |l| l.total_cost.to_f }.round(2) }
  end

  def prepare_monthly_cost_summary
    all_months = Set.new

    fuel_by_month = @fuel_logs
      .select { |l| l.total_cost.present? }
      .group_by { |l| l.log_date&.strftime("%Y-%m") }
    fuel_by_month.each_key { |m| all_months << m if m.present? }

    service_by_month = @service_logs
      .select { |l| l.total_cost.present? }
      .group_by { |l| l.log_date&.strftime("%Y-%m") }
    service_by_month.each_key { |m| all_months << m if m.present? }

    @combined_monthly_labels = all_months.sort
    @combined_fuel_data = @combined_monthly_labels.map { |m| (fuel_by_month[m] || []).sum { |l| l.total_cost.to_f }.round(2) }
    @combined_service_data = @combined_monthly_labels.map { |m| (service_by_month[m] || []).sum { |l| l.total_cost.to_f }.round(2) }
    @combined_monthly_labels = @combined_monthly_labels.map { |m| Date.strptime(m, "%Y-%m").strftime("%b %Y") }
  end

  def prepare_fuel_price_trend
    logs_with_price = @fuel_logs.select { |l| l.price_per_gallon.present? }
    @price_labels = logs_with_price.map { |l| l.log_date&.strftime("%b %d, %Y") }
    @price_data = logs_with_price.map { |l| l.price_per_gallon.to_f }
  end
end
