require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @expense = expenses(:lunch)
  end

  test "should get index" do
    get expenses_url
    assert_response :success
  end

  test "should get new" do
    get new_expense_url
    assert_response :success
  end

  test "should create expense" do
    assert_difference("Expense.count") do
      post expenses_url, params: { expense: { amount: @expense.amount, category_id: @expense.category_id, date: @expense.date, description: @expense.description } }
    end

    assert_redirected_to expense_url(Expense.last)
  end

  test "should show expense" do
    get expense_url(@expense)
    assert_response :success
  end

  test "should get edit" do
    get edit_expense_url(@expense)
    assert_response :success
  end

  test "should update expense" do
    patch expense_url(@expense), params: { expense: { amount: @expense.amount, category_id: @expense.category_id, date: @expense.date, description: @expense.description } }
    assert_redirected_to expense_url(@expense)
  end

  test "should destroy expense" do
    assert_difference("Expense.count", -1) do
      delete expense_url(@expense)
    end

    assert_redirected_to expenses_url
  end

  # Date filtering tests
  test "should filter expenses by start date" do
    get expenses_url, params: { start_date: "2025-10-24" }
    assert_response :success

    # Should include lunch description but not movie description
    assert_match "Lunch at local cafe", response.body
    assert_no_match "Movie ticket", response.body

    # Should include filter value in form
    assert_match 'value="2025-10-24"', response.body
  end

  test "should filter expenses by end date" do
    get expenses_url, params: { end_date: "2025-10-23" }
    assert_response :success

    # Should include gas and movie but not lunch
    assert_match "Gas fill-up", response.body
    assert_match "Movie ticket", response.body
    assert_no_match "Lunch at local cafe", response.body

    # Should include filter value in form
    assert_match 'value="2025-10-23"', response.body
  end

  test "should filter expenses by date range" do
    get expenses_url, params: { start_date: "2025-10-23", end_date: "2025-10-24" }
    assert_response :success

    # Should include lunch and gas but not movie
    assert_match "Lunch at local cafe", response.body
    assert_match "Gas fill-up", response.body
    assert_no_match "Movie ticket", response.body

    # Should include both filter values in form
    assert_match 'value="2025-10-23"', response.body
    assert_match 'value="2025-10-24"', response.body
  end

  test "should return all expenses when no date filters provided" do
    get expenses_url
    assert_response :success

    # Should include all expenses
    assert_match "Lunch at local cafe", response.body
    assert_match "Gas fill-up", response.body
    assert_match "Movie ticket", response.body

    # Should not show Clear Filters link
    assert_no_match "Clear Filters", response.body
  end

  test "should handle empty date filter parameters" do
    get expenses_url, params: { start_date: "", end_date: "" }
    assert_response :success

    # Should include all expenses when params are empty strings
    assert_match "Lunch at local cafe", response.body
    assert_match "Gas fill-up", response.body
    assert_match "Movie ticket", response.body
  end

  test "should show clear filters link when filters are active" do
    get expenses_url, params: { start_date: "2025-10-24" }
    assert_response :success

    # Should show Clear Filters link when filter is applied
    assert_match "Clear Filters", response.body
  end

  # CSV Export tests
  test "should export all expenses to CSV" do
    get expenses_url(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.content_type
    assert_match "attachment", response.headers["Content-Disposition"]
    assert_match "expenses_", response.headers["Content-Disposition"]

    # Check CSV content structure
    csv_lines = response.body.split("\n")
    assert_equal "Date,Category,Amount,Description", csv_lines.first
    assert_equal 4, csv_lines.length # Header + 3 expenses

    # Check for expense data in CSV
    assert_match "2025-10-24,Food & Dining,12.5,Lunch at local cafe", response.body
    assert_match "2025-10-23,Transportation,45.0,Gas fill-up", response.body
    assert_match "2025-10-22,Entertainment,15.0,Movie ticket", response.body
  end

  test "should export filtered expenses to CSV with date range in filename" do
    get expenses_url(format: :csv, start_date: "2025-10-24", end_date: "2025-10-24")
    assert_response :success
    assert_equal "text/csv", response.content_type

    # Check filename includes date range
    assert_match "expenses_2025-10-24_to_2025-10-24.csv", response.headers["Content-Disposition"]

    # Check CSV contains only filtered data
    csv_lines = response.body.split("\n")
    assert_equal 2, csv_lines.length # Header + 1 expense
    assert_match "2025-10-24,Food & Dining,12.5,Lunch at local cafe", response.body
    assert_no_match "Gas fill-up", response.body
  end

  test "should export filtered expenses with start date only" do
    get expenses_url(format: :csv, start_date: "2025-10-23")
    assert_response :success

    # Check filename includes start date
    assert_match "expenses_from_2025-10-23.csv", response.headers["Content-Disposition"]

    # Should include lunch and gas but not movie
    assert_match "Food & Dining", response.body
    assert_match "Transportation", response.body
    assert_no_match "Entertainment", response.body
  end

  test "should export filtered expenses with end date only" do
    get expenses_url(format: :csv, end_date: "2025-10-23")
    assert_response :success

    # Check filename includes end date
    assert_match "expenses_until_2025-10-23.csv", response.headers["Content-Disposition"]

    # Should include gas and movie but not lunch
    assert_match "Transportation", response.body
    assert_match "Entertainment", response.body
    assert_no_match "Food & Dining", response.body
  end
end
