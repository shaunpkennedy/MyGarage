import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.handleSystemChange = this.handleSystemChange.bind(this)
    this.mediaQuery.addEventListener("change", this.handleSystemChange)

    this.preference = localStorage.getItem("theme") || "system"
    this.applyTheme()
    this.updateToggleUI()
  }

  disconnect() {
    this.mediaQuery.removeEventListener("change", this.handleSystemChange)
  }

  select(event) {
    event.preventDefault()
    this.preference = event.currentTarget.dataset.themeValue
    localStorage.setItem("theme", this.preference)
    this.applyTheme()
    this.updateToggleUI()
  }

  applyTheme() {
    const resolved = this.resolvedTheme
    document.documentElement.setAttribute("data-bs-theme", resolved)
  }

  get resolvedTheme() {
    if (this.preference === "system") {
      return this.mediaQuery.matches ? "dark" : "light"
    }
    return this.preference
  }

  handleSystemChange() {
    if (this.preference === "system") {
      this.applyTheme()
    }
  }

  updateToggleUI() {
    const iconMap = { light: "bi-sun-fill", dark: "bi-moon-fill", system: "bi-circle-half" }

    // Update the dropdown toggle icon
    if (this.hasIconTarget) {
      this.iconTarget.className = `bi ${iconMap[this.preference]}`
    }

    // Update active state on dropdown items
    this.element.querySelectorAll("[data-theme-value]").forEach((el) => {
      el.classList.toggle("active", el.dataset.themeValue === this.preference)
    })
  }
}
