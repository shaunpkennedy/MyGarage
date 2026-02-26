# == Schema Information
#
# Table name: vehicles
#
#  id                      :integer          not null, primary key
#  current_odometer        :integer
#  make                    :string
#  model                   :string
#  oil_change_frequency    :integer
#  tire_rotation_frequency :integer
#  title                   :string
#  vin                     :string
#  year                    :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer          not null
#
# Indexes
#
#  index_vehicles_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require "test_helper"

class VehicleTest < ActiveSupport::TestCase
  test "valid vehicle" do
    vehicle = Vehicle.new(user: users(:shaun), title: "New Car")
    assert vehicle.valid?
  end

  test "requires title" do
    vehicle = Vehicle.new(user: users(:shaun))
    assert_not vehicle.valid?
    assert_includes vehicle.errors[:title], "can't be blank"
  end

  test "requires unique title per user" do
    vehicle = Vehicle.new(user: users(:shaun), title: vehicles(:civic).title)
    assert_not vehicle.valid?
  end

  test "allows same title for different users" do
    vehicle = Vehicle.new(user: users(:jane), title: vehicles(:civic).title)
    assert vehicle.valid?
  end

  test "display_name returns year make model" do
    assert_equal "2020 Honda Civic", vehicles(:civic).display_name
  end

  test "display_name falls back to title" do
    vehicle = Vehicle.new(title: "My Car")
    assert_equal "My Car", vehicle.display_name
  end

  test "fuel_total_cost sums fuel log costs" do
    total = vehicles(:civic).fuel_total_cost
    assert_equal fuel_logs(:first_fill).total_cost + fuel_logs(:second_fill).total_cost, total
  end

  test "active_reminders returns only uncompleted" do
    active = vehicles(:civic).active_reminders
    active.each do |r|
      assert_nil r.completed_at
    end
  end

  test "overall_mpg returns 0 with no gallons" do
    assert_equal 0, vehicles(:truck).overall_mpg
  end
end
