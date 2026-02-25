class CostSummariesController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle

  def show
    @view = params[:view] == "yearly" ? :yearly : :monthly
    @fuel_logs = @vehicle.fuel_logs.order(:log_date)
    @service_logs = @vehicle.service_logs.order(:log_date)

    build_period_data
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:vehicle_id])
  end

  def build_period_data
    format = @view == :yearly ? "%Y" : "%Y-%m"

    fuel_grouped = @fuel_logs
      .select { |l| l.total_cost.present? && l.log_date.present? }
      .group_by { |l| l.log_date.strftime(format) }

    service_grouped = @service_logs
      .select { |l| l.total_cost.present? && l.log_date.present? }
      .group_by { |l| l.log_date.strftime(format) }

    all_periods = (fuel_grouped.keys + service_grouped.keys).uniq.sort

    @periods = all_periods.map do |period|
      fuel_entries = fuel_grouped[period] || []
      service_entries = service_grouped[period] || []
      fuel_cost = fuel_entries.sum { |l| l.total_cost.to_f }.round(2)
      service_cost = service_entries.sum { |l| l.total_cost.to_f }.round(2)

      {
        period: format_period(period),
        fuel_cost: fuel_cost,
        service_cost: service_cost,
        total: (fuel_cost + service_cost).round(2),
        fill_ups: fuel_entries.size,
        services: service_entries.size
      }
    end

    @grand_totals = {
      fuel_cost: @periods.sum { |p| p[:fuel_cost] }.round(2),
      service_cost: @periods.sum { |p| p[:service_cost] }.round(2),
      total: @periods.sum { |p| p[:total] }.round(2),
      fill_ups: @periods.sum { |p| p[:fill_ups] },
      services: @periods.sum { |p| p[:services] }
    }
  end

  def format_period(period)
    if @view == :yearly
      period
    else
      Date.strptime(period, "%Y-%m").strftime("%b %Y")
    end
  end
end
