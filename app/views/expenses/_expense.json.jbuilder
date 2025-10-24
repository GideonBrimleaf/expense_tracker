json.extract! expense, :id, :amount, :date, :description, :created_at, :updated_at
json.category do
  json.id expense.category.id
  json.name expense.category.name
end
json.url expense_url(expense, format: :json)
