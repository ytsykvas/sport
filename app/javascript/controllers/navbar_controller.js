import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = ["toggle", "menu"]

  connect() {
    // Initialize menu state based on current classes
    this.isOpen = this.menuTarget.classList.contains("show")
    this.updateToggle()
  }

  toggle() {
    this.isOpen = !this.isOpen
    this.updateMenu()
    this.updateToggle()
  }

  updateMenu() {
    if (this.isOpen) {
      this.menuTarget.classList.add("show")
    } else {
      this.menuTarget.classList.remove("show")
    }
  }

  updateToggle() {
    const expanded = this.isOpen.toString()
    this.toggleTarget.setAttribute("aria-expanded", expanded)
  }
}

