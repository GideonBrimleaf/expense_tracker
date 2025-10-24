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
end
