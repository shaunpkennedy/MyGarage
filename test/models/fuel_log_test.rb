# == Schema Information
#
# Table name: fuel_logs
#
#  id               :integer          not null, primary key
#  gallons          :decimal(6, 3)
#  log_date         :datetime
#  miles            :integer
#  mpg              :decimal(4, 1)
#  odometer         :integer
#  price_per_gallon :decimal(6, 3)
#  total_cost       :decimal(7, 2)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  vehicle_id       :integer          not null
#
# Indexes
#
#  index_fuel_logs_on_vehicle_id  (vehicle_id)
#
# Foreign Keys
#
#  vehicle_id  (vehicle_id => vehicles.id)
#
require "test_helper"

class FuelLogTest < ActiveSupport::TestCase
  test "valid fuel log" do
    log = FuelLog.new(vehicle: vehicles(:civic), odometer: 51000, gallons: 10.0, log_date: Date.current)
    assert log.valid?
  end

  test "requires odometer" do
    log = FuelLog.new(vehicle: vehicles(:civic), gallons: 10.0)
    assert_not log.valid?
    assert_includes log.errors[:odometer], "can't be blank"
  end

  test "requires gallons" do
    log = FuelLog.new(vehicle: vehicles(:civic), odometer: 51000)
    assert_not log.valid?
    assert_includes log.errors[:gallons], "can't be blank"
  end

  test "auto-calculates miles from previous odometer" do
    log = FuelLog.new(vehicle: vehicles(:civic), odometer: 50100, gallons: 10.0, log_date: Date.current)
    log.save!
    assert_equal 300, log.miles  # 50100 - 49800 (second_fill)
  end

  test "auto-calculates mpg" do
    log = FuelLog.new(vehicle: vehicles(:civic), odometer: 50100, gallons: 10.0, log_date: Date.current)
    log.save!
    assert_equal 30.0, log.mpg  # 300 / 10.0
  end

  test "auto-calculates total_cost when blank" do
    log = FuelLog.new(vehicle: vehicles(:civic), odometer: 50100, gallons: 10.0, price_per_gallon: 3.50, log_date: Date.current)
    log.save!
    assert_equal 35.0, log.total_cost
  end

  test "does not overwrite total_cost when provided" do
    log = FuelLog.new(vehicle: vehicles(:civic), odometer: 50100, gallons: 10.0, price_per_gallon: 3.50, total_cost: 40.0, log_date: Date.current)
    log.save!
    assert_equal 40.0, log.total_cost
  end

  test "updates vehicle odometer after save" do
    vehicle = vehicles(:civic)
    FuelLog.create!(vehicle: vehicle, odometer: 51000, gallons: 10.0, log_date: Date.current)
    vehicle.reload
    assert_equal 51000, vehicle.current_odometer
  end
end
