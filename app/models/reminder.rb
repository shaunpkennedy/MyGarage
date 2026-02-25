# frozen_string_literal: true

# == Schema Information
#
# Table name: reminders
#
#  id               :integer          not null, primary key
#  completed_at     :datetime
#  miles            :integer
#  next_odometer    :integer
#  notes            :text
#  recurring        :boolean          default(FALSE)
#  time             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  reminder_type_id :integer          not null
#  service_type_id  :integer          not null
#  vehicle_id       :integer          not null
#
# Indexes
#
#  index_reminders_on_reminder_type_id  (reminder_type_id)
#  index_reminders_on_service_type_id   (service_type_id)
#  index_reminders_on_vehicle_id        (vehicle_id)
#
# Foreign Keys
#
#  reminder_type_id  (reminder_type_id => reminder_types.id)
#  service_type_id   (service_type_id => service_types.id)
#  vehicle_id        (vehicle_id => vehicles.id)
#
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
    create_next_reminder if recurring? && miles.present?
  end

  private

  def create_next_reminder
    Reminder.create!(
      vehicle: vehicle,
      service_type: service_type,
      reminder_type: reminder_type,
      miles: miles,
      time: time,
      next_odometer: next_odometer.to_i + miles,
      notes: notes,
      recurring: true
    )
  end
end
