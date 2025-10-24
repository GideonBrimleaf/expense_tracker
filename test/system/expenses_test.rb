require "application_system_test_case"

class ExpensesTest < ApplicationSystemTestCase
  setup do
    @expense = expenses(:lunch)
  end

  test "visiting the index" do
    visit expenses_url
    assert_selector "h1", text: "Expenses"
  end

  test "should create expense" do
    visit expenses_url
    click_on "New Expense"

    fill_in "Amount", with: @expense.amount
    select @expense.category.name, from: "Category"
    fill_in "Date", with: @expense.date
    fill_in "Description", with: @expense.description
    click_on "Create Expense"

    assert_text "Expense was successfully created"
    click_on "Back"
  end

  test "should update Expense" do
    visit expense_url(@expense)
    click_on "Edit this expense", match: :first

    fill_in "Amount", with: @expense.amount
    select @expense.category.name, from: "Category"
    fill_in "Date", with: @expense.date
    fill_in "Description", with: @expense.description
    click_on "Update Expense"

    assert_text "Expense was successfully updated"
    click_on "Back"
  end

  test "should destroy Expense" do
    visit expense_url(@expense)
    click_on "Destroy this expense", match: :first

    assert_text "Expense was successfully destroyed"
  end

  test "should filter expenses by date range" do
    visit expenses_url

    # Verify all expenses are shown initially
    assert_text "Lunch at local cafe"
    assert_text "Gas fill-up"
    assert_text "Movie ticket"

    # Filter to show only expenses from 2025-10-24 (lunch)
    # Using execute_script - the ONLY reliable method for HTML5 date inputs in tests
    # As demonstrated: find('#date').set('2025-10-24') produces '51024-02-20' ❌
    page.execute_script("document.getElementById('start_date').value = '2025-10-24'")
    page.execute_script("document.getElementById('end_date').value = '2025-10-24'")
    click_on "Filter"

    # Should show only the lunch expense
    assert_text "Lunch at local cafe"
    assert_no_text "Gas fill-up"
    assert_no_text "Movie ticket"

    # Filter form should retain the values
    assert_field "start_date", with: "2025-10-24"
    assert_field "end_date", with: "2025-10-24"

    # Clear Filters link should be visible
    assert_link "Clear Filters"
  end

  test "should filter expenses with start date only" do
    visit expenses_url

    # Filter to show expenses from 2025-10-23 onwards (gas and lunch)
    page.execute_script("document.getElementById('start_date').value = '2025-10-23'")
    click_on "Filter"

    # Should show gas and lunch but not movie
    assert_text "Lunch at local cafe"
    assert_text "Gas fill-up"
    assert_no_text "Movie ticket"

    # Form should retain the start date
    assert_field "start_date", with: "2025-10-23"
    assert_field "end_date", with: ""
  end

  test "should filter expenses with end date only" do
    visit expenses_url

    # Filter to show expenses up to 2025-10-23 (gas and movie)
    page.execute_script("document.getElementById('end_date').value = '2025-10-23'")
    click_on "Filter"

    # Should show gas and movie but not lunch
    assert_text "Gas fill-up"
    assert_text "Movie ticket"
    assert_no_text "Lunch at local cafe"

    # Form should retain the end date
    assert_field "start_date", with: ""
    assert_field "end_date", with: "2025-10-23"
  end

  test "should clear filters and show all expenses" do
    visit expenses_url

    # Apply a filter first
    page.execute_script("document.getElementById('start_date').value = '2025-10-24'")
    page.execute_script("document.getElementById('end_date').value = '2025-10-24'")
    click_on "Filter"

    # Verify filtering worked
    assert_text "Lunch at local cafe"
    assert_no_text "Gas fill-up"

    # Clear the filters
    click_on "Clear Filters"

    # Should show all expenses again
    assert_text "Lunch at local cafe"
    assert_text "Gas fill-up"
    assert_text "Movie ticket"

    # Form fields should be empty
    assert_field "start_date", with: ""
    assert_field "end_date", with: ""

    # Clear Filters link should not be visible
    assert_no_link "Clear Filters"
  end

  test "should handle empty filter results gracefully" do
    visit expenses_url

    # Filter for a date range with no expenses
    page.execute_script("document.getElementById('start_date').value = '2025-01-01'")
    page.execute_script("document.getElementById('end_date').value = '2025-01-01'")
    click_on "Filter"

    # Should show no expenses
    assert_no_text "Lunch at local cafe"
    assert_no_text "Gas fill-up"
    assert_no_text "Movie ticket"

    # Filter form should still be present and functional
    assert_field "start_date", with: "2025-01-01"
    assert_field "end_date", with: "2025-01-01"
    assert_link "Clear Filters"
  end

  test "should display expense chart section" do
    visit expenses_url

    # Chart section should be present when there are expenses
    assert_selector ".chart-section"

    # Toggle buttons should be present
    assert_button "Count"
    assert_button "Amount ($)"

    # Chart should have data attributes
    assert_selector "[data-controller='chart']"

    # Canvas should exist (but may not be visible due to Chart.js loading)
    assert_selector "canvas", visible: false
  end
end
