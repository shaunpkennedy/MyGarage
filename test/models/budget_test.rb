# == Schema Information
#
# Table name: budgets
#
#  id         :integer          not null, primary key
#  amount     :decimal(8, 2)    not null
#  category   :string           not null
#  period     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vehicle_id :integer          not null
#
# Indexes
#
#  index_budgets_on_vehicle_id                          (vehicle_id)
#  index_budgets_on_vehicle_id_and_category_and_period  (vehicle_id,category,period) UNIQUE
#
# Foreign Keys
#
#  vehicle_id  (vehicle_id => vehicles.id)
#
require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  setup do
    @vehicle = vehicles(:civic)
  end

  test "valid budget" do
    budget = Budget.new(vehicle: @vehicle, category: "fuel", period: "yearly", amount: 300)
    assert budget.valid?
  end

  test "requires category" do
    budget = Budget.new(vehicle: @vehicle, period: "monthly", amount: 100)
    assert_not budget.valid?
    assert_includes budget.errors[:category], "can't be blank"
  end

  test "requires period" do
    budget = Budget.new(vehicle: @vehicle, category: "fuel", amount: 100)
    assert_not budget.valid?
    assert_includes budget.errors[:period], "can't be blank"
  end

  test "requires amount" do
    budget = Budget.new(vehicle: @vehicle, category: "fuel", period: "monthly")
    assert_not budget.valid?
    assert_includes budget.errors[:amount], "can't be blank"
  end

  test "amount must be positive" do
    budget = Budget.new(vehicle: @vehicle, category: "fuel", period: "yearly", amount: -10)
    assert_not budget.valid?
    assert_includes budget.errors[:amount], "must be greater than 0"
  end

  test "invalid category rejected" do
    budget = Budget.new(vehicle: @vehicle, category: "food", period: "monthly", amount: 100)
    assert_not budget.valid?
    assert_includes budget.errors[:category], "is not included in the list"
  end

  test "invalid period rejected" do
    budget = Budget.new(vehicle: @vehicle, category: "fuel", period: "weekly", amount: 100)
    assert_not budget.valid?
    assert_includes budget.errors[:period], "is not included in the list"
  end

  test "uniqueness per vehicle+category+period" do
    # civic_fuel_monthly fixture already exists
    budget = Budget.new(vehicle: @vehicle, category: "fuel", period: "monthly", amount: 300)
    assert_not budget.valid?
    assert_includes budget.errors[:category], "already has a budget for this period"
  end

  test "current_spent for fuel monthly sums fuel logs in current month" do
    budget = budgets(:civic_fuel_monthly)
    # Create a fuel log in the current month
    @vehicle.fuel_logs.create!(
      log_date: Time.current,
      odometer: 55000,
      gallons: 10,
      price_per_gallon: 3.50,
      total_cost: 35.00
    )
    assert_equal 35.00, budget.current_spent
  end

  test "current_spent for service yearly sums service logs in current year" do
    budget = budgets(:civic_service_yearly)
    @vehicle.service_logs.create!(
      log_date: Time.current,
      odometer: 55000,
      service_type: service_types(:oil_change),
      total_cost: 50.00
    )
    assert_equal 50.00, budget.current_spent
  end

  test "current_spent for total sums both fuel and service" do
    budget = budgets(:civic_total_monthly)
    @vehicle.fuel_logs.create!(
      log_date: Time.current,
      odometer: 55000,
      gallons: 10,
      price_per_gallon: 3.50,
      total_cost: 35.00
    )
    @vehicle.service_logs.create!(
      log_date: Time.current,
      odometer: 55100,
      service_type: service_types(:oil_change),
      total_cost: 50.00
    )
    assert_equal 85.00, budget.current_spent
  end

  test "percentage_used calculates correctly" do
    budget = budgets(:civic_fuel_monthly)
    @vehicle.fuel_logs.create!(
      log_date: Time.current,
      odometer: 55000,
      gallons: 10,
      price_per_gallon: 3.50,
      total_cost: 100.00
    )
    # 100 / 200 * 100 = 50.0
    assert_equal 50.0, budget.percentage_used
  end

  test "status ok when under 80 percent" do
    budget = budgets(:civic_fuel_monthly)
    # No spending this month in fixtures
    assert_equal :ok, budget.status
  end

  test "status approaching when at 80 percent" do
    budget = budgets(:civic_fuel_monthly) # amount: 200
    @vehicle.fuel_logs.create!(
      log_date: Time.current,
      odometer: 55000,
      gallons: 10,
      price_per_gallon: 3.50,
      total_cost: 160.00
    )
    assert_equal :approaching, budget.status
  end

  test "status exceeded when at 100 percent" do
    budget = budgets(:civic_fuel_monthly) # amount: 200
    @vehicle.fuel_logs.create!(
      log_date: Time.current,
      odometer: 55000,
      gallons: 10,
      price_per_gallon: 3.50,
      total_cost: 250.00
    )
    assert_equal :exceeded, budget.status
  end
end
