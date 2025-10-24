class MigrateCategoryStringToModel < ActiveRecord::Migration[8.0]
  def up
    # Get all unique category names from existing expenses
    unique_categories = Expense.where.not(category: [ nil, "" ]).distinct.pluck(:category)

    # Create Category records for each unique category name
    unique_categories.each do |category_name|
      Category.find_or_create_by(name: category_name)
    end

    # Update each expense to reference the appropriate Category
    Expense.where.not(category: [ nil, "" ]).find_each do |expense|
      category = Category.find_by(name: expense.category)
      expense.update_column(:category_id, category.id) if category
    end

    # For expenses with empty/nil category, create a default "Uncategorized" category
    uncategorized_expenses = Expense.where(category: [ nil, "" ])
    if uncategorized_expenses.exists?
      default_category = Category.find_or_create_by(name: "Uncategorized", description: "Default category for expenses without a specified category")
      uncategorized_expenses.update_all(category_id: default_category.id)
    end
  end

  def down
    # Restore category string values from associated Category names
    Expense.joins(:category).find_each do |expense|
      expense.update_column(:category, expense.category.name)
    end

    # Clear category_id references
    Expense.update_all(category_id: nil)

    # Remove all categories
    Category.delete_all
  end
end
