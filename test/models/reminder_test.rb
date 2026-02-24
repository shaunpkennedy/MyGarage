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
end
