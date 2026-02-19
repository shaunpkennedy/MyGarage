# frozen_string_literal: true

class Reminder < ApplicationRecord
  belongs_to :vehicle
  belongs_to :service_type
  belongs_to :reminder_type, optional: true

  validates :vehicle_id, :service_type_id, presence: true

  scope :active, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }

  def miles_remaining
    return nil unless next_odometer && vehicle.current_odometer

    next_odometer - vehicle.current_odometer
  end

  def overdue?
    miles_remaining&.negative?
  end

  def complete!
    update!(completed_at: Time.current)
  end
end