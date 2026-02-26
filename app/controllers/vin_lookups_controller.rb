class VinLookupsController < ApplicationController
  before_action :authenticate!

  def show
    vin = params[:vin].to_s.strip.upcase

    if vin.blank? || vin.length != 17
      render json: { error: "VIN must be exactly 17 characters" }, status: :unprocessable_entity
      return
    end

    uri = URI("https://vpic.nhtsa.dot.gov/api/vehicles/decodevinvalues/#{vin}?format=json")
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      render json: { error: "NHTSA API request failed" }, status: :service_unavailable
      return
    end

    data = JSON.parse(response.body)
    result = data.dig("Results", 0)

    if result.nil? || result["ErrorCode"].to_s.split(",").all? { |c| c.strip != "0" }
      render json: { error: "Could not decode VIN" }, status: :unprocessable_entity
      return
    end

    render json: {
      make: result["Make"].presence,
      model: result["Model"].presence,
      year: result["ModelYear"].presence
    }
  end
end
