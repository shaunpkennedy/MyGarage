class ReminderMailer < ApplicationMailer
  def reminder_summary(user, overdue_reminders, approaching_reminders)
    @user = user
    @overdue_reminders = overdue_reminders
    @approaching_reminders = approaching_reminders

    mail(
      to: @user.email,
      subject: overdue_reminders.any? ? "MyGarage: You have overdue maintenance" : "MyGarage: Upcoming maintenance reminders"
    )
  end
end
