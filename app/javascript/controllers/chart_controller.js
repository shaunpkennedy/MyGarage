import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js"

export default class extends Controller {
  static values = {
    type: { type: String, default: "line" },
    labels: Array,
    datasets: Array,
    options: { type: Object, default: {} }
  }

  connect() {
    const canvas = this.element.querySelector("canvas")
    if (!canvas) return

    const defaultOptions = {
      responsive: true,
      maintainAspectRatio: true,
      plugins: {
        legend: {
          display: this.datasetsValue.length > 1,
          position: "top"
        }
      }
    }

    if (this.typeValue !== "doughnut") {
      defaultOptions.scales = {
        y: { beginAtZero: true }
      }
    }

    this.chart = new Chart(canvas, {
      type: this.typeValue,
      data: {
        labels: this.labelsValue,
        datasets: this.datasetsValue
      },
      options: { ...defaultOptions, ...this.optionsValue }
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }
}
