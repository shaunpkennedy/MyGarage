class HomeController < ApplicationController
  def index
    if logged_in?
      load_dashboard
      render :dashboard
    end
  end

  private

  def load_dashboard
    @vehicles = current_user.vehicles.includes(:fuel_logs, :service_logs, :reminders)
    @total_spent = @vehicles.sum { |v| v.fuel_total_cost + v.service_total_cost }

    all_active_reminders = Reminder.active
      .joins(:vehicle)
      .where(vehicles: { user_id: current_user.id })
      .includes(:service_type, :vehicle)

    @overdue_reminders = all_active_reminders.select(&:overdue?)
    @approaching_reminders = all_active_reminders.select { |r| r.miles_remaining&.between?(0, 1000) }

    all_budgets = Budget.joins(:vehicle).where(vehicles: { user_id: current_user.id }).includes(:vehicle)
    @exceeded_budgets = all_budgets.select { |b| b.status == :exceeded }
    @approaching_budgets = all_budgets.select { |b| b.status == :approaching }

    fuel_entries = FuelLog.joins(:vehicle)
      .where(vehicles: { user_id: current_user.id })
      .order(log_date: :desc)
      .limit(10)
      .includes(:vehicle)

    service_entries = ServiceLog.joins(:vehicle)
      .where(vehicles: { user_id: current_user.id })
      .order(log_date: :desc)
      .limit(10)
      .includes(:vehicle, :service_type)

    @recent_activity = (fuel_entries + service_entries)
      .sort_by { |e| e.log_date || Time.at(0) }
      .reverse
      .first(10)
  end
end
