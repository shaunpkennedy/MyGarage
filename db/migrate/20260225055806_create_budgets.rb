class CreateBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :budgets do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string :category, null: false
      t.string :period, null: false
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.timestamps
    end
    add_index :budgets, [:vehicle_id, :category, :period], unique: true
  end
end
