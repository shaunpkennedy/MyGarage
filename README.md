# MyGarage

A personal vehicle maintenance tracker for logging fuel fill-ups, service records, and maintenance reminders.

**This is a complete rebuild of [AutoDash](https://github.com/shaunpkennedy/AutoDash)** - modernized from Rails 5 to Rails 7 with a fresh architecture.

## Features

- **Multiple Vehicles** - Track as many cars as you own
- **Fuel Logs** - Record fill-ups with price, gallons, and automatic MPG calculation
- **Service Logs** - Track maintenance like oil changes, tire rotations, brake jobs
- **Reminders** - Mileage-based service reminders so you never miss maintenance
- **Dashboard Stats** - Overall MPG, cost per mile, fuel costs, and more

## Tech Stack

- **Ruby on Rails 7.2** - Modern Rails with Hotwire/Turbo
- **SQLite** - Simple, file-based database (easy backups, no server needed)
- **Bootstrap 5** - Mobile-friendly responsive design
- **Importmaps** - No Node.js/Webpack required

## Calculated Vehicle Stats

- Total fuel cost / service cost
- Overall MPG, most recent MPG, best MPG
- Cost per mile
- Average cost per gallon
- Average cost per fill-up
- Active maintenance reminders

## Getting Started

```bash
# Clone the repo
git clone https://github.com/shaunpkennedy/MyGarage.git
cd MyGarage

# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start the server
bin/dev
```

## Deployment

Designed for easy deployment to [Render](https://render.com) or similar platforms with SQLite support.

## History

Originally started as **AutoDash** in 2017 using Rails 5 and PostgreSQL. This version is a ground-up rebuild using modern Rails conventions and a simpler SQLite-based architecture for personal use.

## License

MIT