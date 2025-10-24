json.extract! category, :id, :name, :description, :created_at, :updated_at
json.expenses_count category.expenses.count
json.url category_url(category, format: :json)
