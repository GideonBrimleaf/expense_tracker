import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chart"
// Uses global Chart.js loaded via script tag
export default class extends Controller {
  static values = { 
    labels: Array,
    countData: Array, 
    amountData: Array 
  }
  static targets = ["canvas", "countButton", "amountButton"]

  connect() {
    this.currentMode = "count"
    this.attempts = 0
    
    // Wait for Chart.js to load, then initialize
    this.waitForChart()
  }

  waitForChart() {
    this.attempts += 1
    
    if (typeof Chart !== 'undefined') {
      this.initializeChartWhenReady()
    } else if (this.attempts < 50) { // Max 5 seconds
      // Check again in 100ms
      setTimeout(() => this.waitForChart(), 100)
    } else {
      console.error("Chart.js failed to load after 5 seconds")
      this.showChartError()
    }
  }

  initializeChartWhenReady() {
    console.log("Chart.js version:", Chart.version)
    console.log("Chart data:", { 
      labels: this.labelsValue, 
      counts: this.countDataValue, 
      amounts: this.amountDataValue 
    })
    
    try {
      this.initializeChart()
      this.updateButtonStates()
      console.log("Chart initialized successfully!")
    } catch (error) {
      console.error("Chart initialization error:", error)
      this.showChartError()
    }
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  initializeChart() {
    // Hide loading message and show canvas
    const loadingDiv = this.element.querySelector('.chart-loading')
    if (loadingDiv) loadingDiv.style.display = 'none'
    this.canvasTarget.style.display = 'block'
    
    const ctx = this.canvasTarget.getContext('2d')
    
    // Generate colors for pie chart segments
    const colors = this.generateColors(this.labelsValue.length)
    
    this.chart = new Chart(ctx, {
      type: 'pie',
      data: {
        labels: this.labelsValue,
        datasets: [{
          data: this.countDataValue,
          backgroundColor: colors.background,
          borderColor: colors.border,
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom',
          },
          title: {
            display: true,
            text: 'Expenses by Category (Count)'
          }
        }
      }
    })
  }

  toggleToCount() {
    this.currentMode = "count"
    this.updateChart()
    this.updateButtonStates()
  }

  toggleToAmount() {
    this.currentMode = "amount"
    this.updateChart()
    this.updateButtonStates()
  }

  updateChart() {
    const data = this.currentMode === "count" ? this.countDataValue : this.amountDataValue
    const title = this.currentMode === "count" ? 
      "Expenses by Category (Count)" : 
      "Expenses by Category (Amount)"
    
    this.chart.data.datasets[0].data = data
    this.chart.options.plugins.title.text = title
    this.chart.update()
  }

  updateButtonStates() {
    // Update button active states
    if (this.currentMode === "count") {
      this.countButtonTarget.classList.add("active")
      this.amountButtonTarget.classList.remove("active")
    } else {
      this.countButtonTarget.classList.remove("active")
      this.amountButtonTarget.classList.add("active")
    }
  }

  generateColors(count) {
    const colors = [
      '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
      '#FF9F40', '#FF6384', '#C9CBCF', '#4BC0C0', '#FF6384'
    ]
    
    return {
      background: colors.slice(0, count),
      border: colors.slice(0, count).map(color => color.replace('0.2', '1'))
    }
  }

  showChartError() {
    const chartContainer = this.element.querySelector('.chart-container')
    chartContainer.innerHTML = '<p style="text-align: center; padding: 2rem; color: #666;">Chart could not be loaded. Please refresh the page.</p>'
  }
}