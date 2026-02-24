import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["ppg", "gallons", "totalCost"]

  calculate() {
    const ppg = parseFloat(this.ppgTarget.value)
    const gallons = parseFloat(this.gallonsTarget.value)

    if (!isNaN(ppg) && !isNaN(gallons) && ppg > 0 && gallons > 0) {
      this.totalCostTarget.value = (ppg * gallons).toFixed(2)
    }
  }
}
