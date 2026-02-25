namespace :reminders do
  desc "Send email notifications for overdue and approaching maintenance reminders"
  task notify: :environment do
    ReminderNotificationJob.perform_now
  end
end
