class AddRecurringToReminders < ActiveRecord::Migration[8.1]
  def change
    add_column :reminders, :recurring, :boolean, default: false
  end
end
