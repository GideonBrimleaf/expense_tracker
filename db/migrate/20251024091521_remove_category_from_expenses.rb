class RemoveCategoryFromExpenses < ActiveRecord::Migration[8.0]
  def change
    remove_column :expenses, :category, :string
  end
end
