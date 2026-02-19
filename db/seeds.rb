# frozen_string_literal: true

# Seed default service types and reminder types
ServiceType.seed_defaults!
ReminderType.seed_defaults!

puts "Seeded #{ServiceType.count} service types"
puts "Seeded #{ReminderType.count} reminder types"