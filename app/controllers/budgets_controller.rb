class BudgetsController < ApplicationController
  before_action :authenticate!
  before_action :set_vehicle
  before_action :set_budget, only: %i[show edit update destroy]

  def index
    @budgets = @vehicle.budgets.order(:category, :period)
  end

  def show
  end

  def new
    @budget = @vehicle.budgets.build
  end

  def create
    @budget = @vehicle.budgets.build(budget_params)

    if @budget.save
      flash[:notice] = "Budget created."
      redirect_to vehicle_budgets_path(@vehicle)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @budget.update(budget_params)
      flash[:notice] = "Budget updated."
      redirect_to vehicle_budgets_path(@vehicle)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @budget.destroy
    flash[:notice] = "Budget removed."
    redirect_to vehicle_budgets_path(@vehicle)
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:vehicle_id])
  end

  def set_budget
    @budget = @vehicle.budgets.find(params[:id])
  end

  def budget_params
    params.require(:budget).permit(:category, :period, :amount)
  end
end
