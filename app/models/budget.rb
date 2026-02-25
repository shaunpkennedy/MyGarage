# frozen_string_literal: true

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
class Budget < ApplicationRecord
  CATEGORIES = %w[fuel service total].freeze
  PERIODS = %w[monthly yearly].freeze

  belongs_to :vehicle

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :period, presence: true, inclusion: { in: PERIODS }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, uniqueness: { scope: [:vehicle_id, :period], message: "already has a budget for this period" }

  def current_spent
    range = period_range
    fuel = 0
    service = 0

    if category == "fuel" || category == "total"
      fuel = vehicle.fuel_logs.where(log_date: range).sum(:total_cost)
    end

    if category == "service" || category == "total"
      service = vehicle.service_logs.where(log_date: range).sum(:total_cost)
    end

    fuel + service
  end

  def percentage_used
    return 0 if amount.zero?
    (current_spent / amount * 100).round(1)
  end

  def status
    pct = percentage_used
    if pct >= 100
      :exceeded
    elsif pct >= 80
      :approaching
    else
      :ok
    end
  end

  private

  def period_range
    now = Time.current
    if period == "monthly"
      now.beginning_of_month..now.end_of_month
    else
      now.beginning_of_year..now.end_of_year
    end
  end
end
