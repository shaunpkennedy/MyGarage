class CreateReminders < ActiveRecord::Migration[7.2]
  def change
    create_table :reminders do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true
      t.references :reminder_type, null: false, foreign_key: true
      t.integer :miles
      t.integer :time
      t.integer :next_odometer
      t.text :notes
      t.datetime :completed_at

      t.timestamps
    end
  end
end
