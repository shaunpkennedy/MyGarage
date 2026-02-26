class FuelTrendsController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle

  def show
    @fuel_logs = @vehicle.fuel_logs
      .where.not(price_per_gallon: nil)
      .where.not(log_date: nil)
      .order(:log_date)

    build_monthly_data
    fetch_national_averages
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:vehicle_id])
  end

  def build_monthly_data
    grouped = @fuel_logs.group_by { |l| l.log_date.strftime("%Y-%m") }

    @months = grouped.map do |month, logs|
      avg_price = (logs.sum { |l| l.price_per_gallon.to_f } / logs.size).round(3)
      min_price = logs.map { |l| l.price_per_gallon.to_f }.min.round(3)
      max_price = logs.map { |l| l.price_per_gallon.to_f }.max.round(3)
      total_gallons = logs.sum { |l| l.gallons.to_f }.round(1)
      total_cost = logs.sum { |l| l.total_cost.to_f }.round(2)

      {
        month: month,
        label: Date.strptime(month, "%Y-%m").strftime("%b %Y"),
        avg_price: avg_price,
        min_price: min_price,
        max_price: max_price,
        fill_ups: logs.size,
        total_gallons: total_gallons,
        total_cost: total_cost
      }
    end

    if @fuel_logs.any?
      all_prices = @fuel_logs.map { |l| l.price_per_gallon.to_f }
      @stats = {
        avg: (all_prices.sum / all_prices.size).round(3),
        min: all_prices.min.round(3),
        max: all_prices.max.round(3),
        latest: all_prices.last.round(3),
        total_spent: @fuel_logs.sum { |l| l.total_cost.to_f }.round(2),
        total_gallons: @fuel_logs.sum { |l| l.gallons.to_f }.round(1)
      }
    end
  end

  def fetch_national_averages
    @national_averages = []
    api_key = ENV["EIA_API_KEY"]
    return if api_key.blank? || @months.blank?

    start_month = @months.first[:month]
    end_month = @months.last[:month]

    uri = URI("https://api.eia.gov/v2/petroleum/pri/gnd/data/")
    uri.query = URI.encode_www_form(
      api_key: api_key,
      frequency: "monthly",
      "data[]" => "value",
      "facets[product][]" => "EMM_EPMR_PTE_NUS_DPG",
      "start" => start_month,
      "end" => end_month,
      "sort[0][column]" => "period",
      "sort[0][direction]" => "asc"
    )

    response = Net::HTTP.get_response(uri)
    return unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    records = data.dig("response", "data") || []

    @national_averages = records.filter_map do |r|
      next unless r["period"] && r["value"]
      { month: r["period"], price: r["value"].to_f.round(3) }
    end
  rescue StandardError
    @national_averages = []
  end
end
