class ReminderNotificationJob < ApplicationJob
  queue_as :default

  APPROACHING_THRESHOLD = 1000 # miles

  def perform
    User.joins(vehicles: :reminders)
        .where(reminders: { completed_at: nil })
        .distinct
        .find_each do |user|
      send_reminders_for(user)
    end
  end

  private

  def send_reminders_for(user)
    active = Reminder.active
                     .joins(:vehicle)
                     .where(vehicles: { user_id: user.id })
                     .includes(:vehicle, :service_type)

    overdue = active.select(&:overdue?)
    approaching = active.reject(&:overdue?).select { |r| r.miles_remaining && r.miles_remaining <= APPROACHING_THRESHOLD }

    return if overdue.empty? && approaching.empty?

    ReminderMailer.reminder_summary(user, overdue, approaching).deliver_later
  end
end
