require "test_helper"

class BudgetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:shaun))
    @vehicle = vehicles(:civic)
    @budget = budgets(:civic_fuel_monthly)
  end

  test "index shows budgets" do
    get vehicle_budgets_path(@vehicle)
    assert_response :success
  end

  test "show budget" do
    get vehicle_budget_path(@vehicle, @budget)
    assert_response :success
  end

  test "new budget form" do
    get new_vehicle_budget_path(@vehicle)
    assert_response :success
  end

  test "create budget" do
    assert_difference("Budget.count", 1) do
      post vehicle_budgets_path(@vehicle), params: {
        budget: { category: "fuel", period: "yearly", amount: 2000.00 }
      }
    end
    assert_redirected_to vehicle_budgets_path(@vehicle)
  end

  test "edit budget form" do
    get edit_vehicle_budget_path(@vehicle, @budget)
    assert_response :success
  end

  test "update budget" do
    patch vehicle_budget_path(@vehicle, @budget), params: {
      budget: { amount: 300.00 }
    }
    assert_redirected_to vehicle_budgets_path(@vehicle)
    assert_equal 300.00, @budget.reload.amount.to_f
  end

  test "destroy budget" do
    assert_difference("Budget.count", -1) do
      delete vehicle_budget_path(@vehicle, @budget)
    end
    assert_redirected_to vehicle_budgets_path(@vehicle)
  end

  test "rejects unauthenticated access" do
    delete logout_path
    get vehicle_budgets_path(@vehicle)
    assert_redirected_to login_path
  end

  test "cannot access another users budgets" do
    jane_vehicle = vehicles(:jane_car)
    get vehicle_budgets_path(jane_vehicle)
    assert_response :not_found
  end
end
