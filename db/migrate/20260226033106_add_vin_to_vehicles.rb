class AddVinToVehicles < ActiveRecord::Migration[8.1]
  def change
    add_column :vehicles, :vin, :string
  end
end
