class CreateServiceLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :service_logs do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true
      t.datetime :log_date
      t.integer :odometer
      t.decimal :total_cost, precision: 7, scale: 2
      t.text :notes

      t.timestamps
    end
  end
end
