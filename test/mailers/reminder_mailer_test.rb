require "test_helper"

class ReminderMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:shaun)
    @overdue = [reminders(:overdue_reminder)]
    @approaching = [reminders(:oil_reminder)]
  end

  test "reminder_summary with overdue reminders" do
    email = ReminderMailer.reminder_summary(@user, @overdue, @approaching)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["shaun@example.com"], email.to
    assert_match "overdue maintenance", email.subject
    assert_match "Tire Rotation", email.html_part.body.to_s
    assert_match "Oil Change", email.html_part.body.to_s
  end

  test "reminder_summary with only approaching reminders" do
    email = ReminderMailer.reminder_summary(@user, [], @approaching)

    assert_equal ["shaun@example.com"], email.to
    assert_match "Upcoming maintenance", email.subject
    assert_match "Oil Change", email.html_part.body.to_s
  end

  test "text part includes reminder details" do
    email = ReminderMailer.reminder_summary(@user, @overdue, @approaching)

    assert_match "Tire Rotation", email.text_part.body.to_s
    assert_match "Overdue by", email.text_part.body.to_s
    assert_match "Oil Change", email.text_part.body.to_s
  end
end
