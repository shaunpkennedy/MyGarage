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
require "test_helper"

class ReminderTest < ActiveSupport::TestCase
  test "miles_remaining calculates correctly" do
    reminder = reminders(:oil_reminder)
    expected = reminder.next_odometer - reminder.vehicle.current_odometer
    assert_equal expected, reminder.miles_remaining
  end

  test "overdue returns true when past next_odometer" do
    assert reminders(:overdue_reminder).overdue?
  end

  test "overdue returns false when not past" do
    assert_not reminders(:oil_reminder).overdue?
  end

  test "complete! sets completed_at" do
    reminder = reminders(:oil_reminder)
    assert_nil reminder.completed_at
    reminder.complete!
    assert_not_nil reminder.completed_at
  end

  test "active scope returns only uncompleted" do
    Reminder.active.each do |r|
      assert_nil r.completed_at
    end
  end

  test "completed scope returns only completed" do
    reminders(:oil_reminder).complete!
    Reminder.completed.each do |r|
      assert_not_nil r.completed_at
    end
  end

  test "complete! on recurring reminder creates new active reminder" do
    reminder = reminders(:recurring_reminder)
    assert_difference "Reminder.count", 1 do
      reminder.complete!
    end

    new_reminder = Reminder.active.where(vehicle: reminder.vehicle, service_type: reminder.service_type).last
    assert new_reminder.present?
    assert_equal reminder.next_odometer + reminder.miles, new_reminder.next_odometer
    assert_equal reminder.miles, new_reminder.miles
    assert new_reminder.recurring?
    assert_nil new_reminder.completed_at
  end

  test "complete! on non-recurring reminder does not create new reminder" do
    reminder = reminders(:oil_reminder)
    assert_no_difference "Reminder.count" do
      reminder.complete!
    end
  end
end
