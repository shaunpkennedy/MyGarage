class CreateVehicles < ActiveRecord::Migration[7.2]
  def change
    create_table :vehicles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :make
      t.string :model
      t.integer :year
      t.integer :current_odometer
      t.integer :oil_change_frequency
      t.integer :tire_rotation_frequency

      t.timestamps
    end
  end
end
