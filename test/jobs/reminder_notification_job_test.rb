require "test_helper"

class ReminderNotificationJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends email to user with overdue reminders" do
    assert_enqueued_emails 1 do
      ReminderNotificationJob.perform_now
    end
  end

  test "does not send email to user with no active reminders" do
    Reminder.update_all(completed_at: Time.current)

    assert_no_enqueued_emails do
      ReminderNotificationJob.perform_now
    end
  end

  test "does not send email when reminders are not approaching" do
    # Set next_odometer far in the future so nothing is overdue or approaching
    Reminder.update_all(next_odometer: 999_999)

    assert_no_enqueued_emails do
      ReminderNotificationJob.perform_now
    end
  end
end
