class CreateFuelLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :fuel_logs do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.datetime :log_date
      t.integer :odometer
      t.decimal :price_per_gallon, precision: 6, scale: 3
      t.decimal :gallons, precision: 6, scale: 3
      t.decimal :total_cost, precision: 7, scale: 2
      t.integer :miles
      t.decimal :mpg, precision: 4, scale: 1

      t.timestamps
    end
  end
end
