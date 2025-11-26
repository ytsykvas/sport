import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    // Load saved theme or default to light
    const savedTheme = localStorage.getItem('theme') || 'light'
    this.setTheme(savedTheme)
  }

  toggle() {
    const currentTheme = document.body.getAttribute('data-theme')
    const newTheme = currentTheme === 'light' ? 'dark' : 'light'
    this.setTheme(newTheme)
  }

  setTheme(theme) {
    // Set attributes on <html> tag for Bootstrap and global scope
    document.documentElement.setAttribute('data-theme', theme)
    document.documentElement.setAttribute('data-bs-theme', theme)

    // Also set on body just in case specific selectors use it
    document.body.setAttribute('data-theme', theme)
    document.body.setAttribute('data-bs-theme', theme)

    localStorage.setItem('theme', theme)

    // Update toggle button if it exists
    if (this.hasToggleTarget) {
      this.updateToggleButton(theme)
    }
  }

  updateToggleButton(theme) {
    // Check if toggleTarget is the icon itself or contains an icon
    const icon = this.toggleTarget.tagName === 'I' 
      ? this.toggleTarget 
      : this.toggleTarget.querySelector('i')
    
    if (!icon) return
    
    if (theme === 'dark') {
      icon.classList.remove('bi-moon-stars-fill')
      icon.classList.add('bi-sun-fill')
    } else {
      icon.classList.remove('bi-sun-fill')
      icon.classList.add('bi-moon-stars-fill')
    }
  }
}
