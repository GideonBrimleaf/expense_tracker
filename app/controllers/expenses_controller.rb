class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[ show edit update destroy ]

  # GET /expenses or /expenses.json
  def index
    @expenses = Expense.includes(:category)

    # Apply date range filtering
    if params[:start_date].present?
      @expenses = @expenses.where("date >= ?", params[:start_date])
    end

    if params[:end_date].present?
      @expenses = @expenses.where("date <= ?", params[:end_date])
    end

    @expenses = @expenses.order(date: :desc)

    # Store filter params for form persistence
    @start_date = params[:start_date]
    @end_date = params[:end_date]

    # Prepare chart data for the filtered expenses
    @chart_data = prepare_chart_data(@expenses)

    # Handle CSV export format
    respond_to do |format|
      format.html # Default HTML response
      format.csv { export_to_csv(@expenses) }
    end
  end

  # GET /expenses/1 or /expenses/1.json
  def show
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
  end

  # GET /expenses/1/edit
  def edit
  end

  # POST /expenses or /expenses.json
  def create
    @expense = Expense.new(expense_params)

    respond_to do |format|
      if @expense.save
        format.html { redirect_to @expense, notice: "Expense was successfully created." }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expenses/1 or /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to @expense, notice: "Expense was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1 or /expenses/1.json
  def destroy
    @expense.destroy!

    respond_to do |format|
      format.html { redirect_to expenses_path, notice: "Expense was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def expense_params
      params.expect(expense: [ :amount, :category_id, :date, :description ])
    end

    # Prepare chart data for pie chart visualization
    def prepare_chart_data(expenses)
      # Group by category and calculate counts and amounts
      category_counts = expenses.joins(:category).group("categories.name").count
      category_amounts = expenses.joins(:category).group("categories.name").sum(:amount)

      # Extract labels (category names)
      labels = category_counts.keys

      # Return structured data for Chart.js
      {
        labels: labels,
        count_data: category_counts.values,
        amount_data: category_amounts.values.map(&:to_f)
      }
    end

    # Export expenses to CSV format
    def export_to_csv(expenses)
      require "csv"

      # Generate filename with date range if applicable
      filename = generate_csv_filename

      csv_data = CSV.generate(headers: true) do |csv|
        # Add header row
        csv << [ "Date", "Category", "Amount", "Description" ]

        # Add data rows
        expenses.includes(:category).each do |expense|
          csv << [
            expense.date.strftime("%Y-%m-%d"),
            expense.category.name,
            expense.amount.to_f,
            expense.description
          ]
        end
      end

      send_data csv_data,
                filename: filename,
                type: "text/csv",
                disposition: "attachment"
    end

    # Generate appropriate filename based on filters
    def generate_csv_filename
      base_name = "expenses"

      if @start_date.present? && @end_date.present?
        "#{base_name}_#{@start_date}_to_#{@end_date}.csv"
      elsif @start_date.present?
        "#{base_name}_from_#{@start_date}.csv"
      elsif @end_date.present?
        "#{base_name}_until_#{@end_date}.csv"
      else
        "#{base_name}_#{Date.current.strftime('%Y-%m-%d')}.csv"
      end
    end
end
