# 💸 Expense Tracker - Because Money Doesn't Track Itself!

Welcome to your new favorite expense tracking companion! 🎉 This Rails 8 application helps you keep tabs on where your hard-earned cash disappears to (spoiler alert: it's probably coffee and takeout).

## 🚀 What Does This Thing Do?

This delightful little app lets you:
- **Track your expenses** with categories (because "miscellaneous" isn't a real budget category, Karen)
- **Filter by date ranges** to see exactly how much you spent on "essential" purchases last month
- **Visualize your spending** with pretty pie charts that make financial responsibility look almost fun
- **Export to CSV** because spreadsheets are the true language of adulting
- **Full CRUD operations** for both expenses and categories (Create, Read, Update, Delete - the four horsemen of data management)

Built with modern Rails 8 goodness, Hotwire magic ✨, and just the right amount of JavaScript to make things sparkle without breaking your brain.

## 🛠️ Tech Stack (The Good Stuff)

**Ruby & Rails:**
- Ruby (whatever version your system is running - this app isn't picky!)
- Rails 8.0.2+ (the shiny new version with all the bells and whistles)
- SQLite3 (because sometimes simple is better)
- Puma web server (fast like a... well, puma)

**The Hotwire Trinity:**
- Turbo Rails (SPA-like magic without the SPA complexity)
- Stimulus (JavaScript that doesn't make you want to cry)
- Importmap (ES6 modules without the build step nightmare)

**Background Jobs & Caching:**
- Solid Queue (job processing that actually works)
- Solid Cache (caching that's solid, get it?)
- Solid Cable (WebSockets for the future)

**Frontend Styling & Visualization:**
- [Simple.css](https://simplecss.org/) via CDN (clean, semantic styling that just works)
- [Chart.js 3.9.1](https://www.chartjs.org/) via CDN (pie charts that don't lie about your spending habits)

**Testing & Quality:**
- Capybara + Selenium (system tests that actually test the system)
- Brakeman (security scanning because hackers love expense data)
- RuboCop Rails Omakase (opinionated code formatting, the Rails way)

**Deployment Ready:**
- Kamal (Docker deployment made simple)
- Thruster (HTTP caching and compression)

## 🏃‍♂️ Getting Started (The Easy Way)

### 1. Install Dependencies & Set Up the Project

Rails 8 comes with a magical setup script that does all the heavy lifting:

```bash
# Clone this repository (if you haven't already)
git clone <your-repo-url>
cd expense_tracker

# Run the one-command setup (installs gems, sets up database, starts server)
bin/setup
```

That's it! The `bin/setup` script will:
- Install all Ruby gems
- Set up the SQLite database
- Run any pending migrations
- Seed the database with sample data
- Start the development server

If the setup script doesn't start the server automatically, or if you need to restart it later:

### 2. Start the Application Locally

```bash
# Start the development server with hot reloading
bin/dev
```

Then visit `http://localhost:3000` and start tracking those expenses! 🎯

### 3. Running Tests (Because We're Professionals Here)

This app comes with a comprehensive test suite that actually tests things:

```bash
# Run all tests (unit + system tests)
bin/rails test

# Run just the system tests (the ones with the browser automation)
bin/rails test:system

# Run just the unit tests (controllers, models, etc.)
bin/rails test:units

# Run tests for a specific file
bin/rails test test/controllers/expenses_controller_test.rb

# Run a specific test
bin/rails test test/system/expenses_test.rb -n test_should_export_filtered_expenses_to_csv
```

**Test Coverage Highlights:**
- 24 tests covering all functionality
- System tests for user workflows (filtering, charting, CSV export)
- Controller tests for API responses and edge cases  
- Model tests for validations and associations

## 🎨 Development Goodies

**Code Quality & Security:**
```bash
# Run security analysis
bin/brakeman --no-pager

# Run code linting (Rails Omakase style)
bin/rubocop -f github

# Check JavaScript dependencies for vulnerabilities  
bin/importmap audit
```

**Database Management:**
```bash
# Reset/recreate the database
bin/rails db:prepare

# Generate new migrations
bin/rails generate migration AddAwesomeFeature

# Check migration status
bin/rails db:migrate:status
```

## 🐳 Deployment (When You're Ready for the Big Leagues)

This app is containerized and ready for deployment with Kamal:

```bash
# First-time deployment setup
bin/kamal setup

# Deploy updates  
bin/kamal deploy

# Access remote Rails console
bin/kamal console
```

## 🤝 Contributing

Found a bug? Have a feature idea? Want to make the charts even prettier? 

1. Fork it
2. Create your feature branch (`git checkout -b my-awesome-feature`)
3. Write tests (because future you will thank present you)
4. Make sure tests pass (`bin/rails test`)
5. Run the linter (`bin/rubocop`)
6. Commit your changes (`git commit -am 'Add some awesome feature'`)
7. Push to the branch (`git push origin my-awesome-feature`) 
8. Create a Pull Request

## 📝 License

This project is open source and available under the MIT License. Use it, abuse it, make it better! 

---

*Happy expense tracking! May your categories be organized and your budgets be... well, at least tracked. 📊💰*
