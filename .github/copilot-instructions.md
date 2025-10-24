# Copilot Instructions for Expense Tracker

## Architecture Overview

This is a **Rails 8** expense tracking application using SQLite with modern Rails stack:
- **Hotwire** (Turbo + Stimulus) for SPA-like interactions
- **Solid Queue/Cache/Cable** for background jobs, caching, and WebSockets
- **Kamal** for containerized deployment
- **Importmap** for JavaScript (no Node.js/npm)

### Key Design Patterns

- **Single Resource Focus**: The app centers around `Expense` model with standard Rails CRUD
- **API-First Views**: All controller actions support both HTML and JSON via `respond_to`
- **Modern Rails Conventions**: Uses Rails 8 `params.expect()` instead of strong parameters
- **Container-Ready**: Configured for Docker deployment with Thruster/Puma

## Development Workflow

### Setup & Running
```bash
bin/setup              # One-time setup (installs deps, prepares DB, starts server)
bin/dev                # Start development server
bin/rails db:prepare   # Reset/setup database
```

### Testing & Quality
```bash
bin/rails test                    # Run all tests
bin/rails test:system            # System tests with Capybara
bin/brakeman --no-pager         # Security scan
bin/rubocop -f github           # Linting (omakase style)
bin/importmap audit             # JS dependency security scan
```

## Data Model

### Expense Schema (`app/models/expense.rb`)
```ruby
# Fields: amount (decimal), category (string), date (date), description (text)
# No validations or business logic yet - pure ActiveRecord model
```

**Pattern**: Keep models thin initially, add validations/methods as features grow.

## Frontend Architecture

### JavaScript Setup
- **No Build Step**: Uses Rails importmap for pure ES6 imports
- **Stimulus Controllers**: Place interactive behavior in `app/javascript/controllers/`
- **Turbo Drive**: Automatic SPA behavior - avoid full page reloads

### View Patterns
- **Partial Templates**: Use `_expense.html.erb` for consistent rendering
- **Form Helpers**: Standard `form_with(model:)` with Rails UJS
- **Error Handling**: Inline error display in forms (`expense.errors.any?`)

## Controller Conventions

### Rails 8 Parameter Handling
```ruby
# Use params.expect() instead of strong_parameters
def expense_params
  params.expect(expense: [:amount, :category, :date, :description])
end

def set_expense
  @expense = Expense.find(params.expect(:id))
end
```

### Response Patterns
```ruby
# Always support both HTML and JSON
respond_to do |format|
  format.html { redirect_to @expense, notice: "Success" }
  format.json { render :show, status: :created }
end
```

## Deployment & Production

### Kamal Configuration
- **Single Server Setup**: Configured for basic deployment to `192.168.0.1`
- **SSL**: Auto-certification via Let's Encrypt through proxy
- **Storage**: Persistent volume for SQLite and Active Storage files
- **Jobs**: Solid Queue runs in Puma process (`SOLID_QUEUE_IN_PUMA: true`)

### Docker Workflow
```bash
# Local container testing
docker build -t expense_tracker .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=$(cat config/master.key) expense_tracker

# Kamal deployment
bin/kamal setup    # First-time deployment
bin/kamal deploy   # Updates
bin/kamal console  # Remote Rails console
```

## Adding Features

### New Expense Fields
1. Add migration: `bin/rails generate migration AddFieldToExpenses field:type`
2. Update `expense_params` in controller
3. Add form fields in `_form.html.erb`
4. Update JSON views in `*.json.jbuilder` files

### Interactive Features
1. Generate Stimulus controller: `bin/rails generate stimulus FeatureName`
2. Add `data-controller="feature-name"` to HTML
3. Use Turbo Streams for dynamic updates without JavaScript

## Testing Patterns

### Model Tests (`test/models/`)
- Start with basic validations and associations
- Use fixtures in `test/fixtures/expenses.yml`

### System Tests (`test/system/`)
- Test full user workflows with Capybara
- Screenshots saved on failure to `tmp/screenshots/`
- Use `driven_by :selenium` for JavaScript testing

## Security & Quality

- **Brakeman**: Scans for Rails-specific security issues
- **RuboCop Omakase**: Rails team's opinionated style guide
- **Importmap Audit**: Checks JavaScript dependencies for vulnerabilities
- **CSP**: Content Security Policy configured in `application.html.erb`

## Common Gotchas

- **SQLite in Production**: Uses persistent volumes, suitable for single-server deployments
- **No Node.js**: All JavaScript goes through importmap - no npm packages
- **Thruster**: Production uses Thruster proxy, not direct Puma access
- **Rails 8 Params**: Use `params.expect()` not `params.require().permit()`