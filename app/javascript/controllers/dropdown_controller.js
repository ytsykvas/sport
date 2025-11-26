import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  connect() {
    this.boundInitialize = this.initializeDropdown.bind(this)
    this.boundClickOutside = this.handleClickOutside.bind(this)
    
    // Listen for Turbo events to reinitialize after navigation
    document.addEventListener('turbo:load', this.boundInitialize)
    document.addEventListener('turbo:render', this.boundInitialize)
    document.addEventListener('click', this.boundClickOutside)
    
    // Initialize dropdown
    this.initializeDropdown()
  }

  disconnect() {
    document.removeEventListener('turbo:load', this.boundInitialize)
    document.removeEventListener('turbo:render', this.boundInitialize)
    document.removeEventListener('click', this.boundClickOutside)
    
    if (this.dropdownInstance) {
      this.dropdownInstance.dispose()
      this.dropdownInstance = null
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    // If Bootstrap is available, use it
    if (this.dropdownInstance) {
      this.dropdownInstance.toggle()
    } else {
      // Fallback: manually toggle the dropdown
      this.manualToggle()
    }
  }

  handleClickOutside(event) {
    const menu = this.getMenu()
    if (!menu) return
    
    // If click is outside the dropdown, close it
    if (!this.element.contains(event.target) && !menu.contains(event.target)) {
      if (menu.classList.contains('show')) {
        if (this.dropdownInstance) {
          this.dropdownInstance.hide()
        } else {
          this.manualToggle()
        }
      }
    }
  }

  getMenu() {
    // Find the dropdown menu - it should be the next sibling ul with class dropdown-menu
    let sibling = this.element.nextElementSibling
    while (sibling) {
      if (sibling.classList && sibling.classList.contains('dropdown-menu')) {
        return sibling
      }
      sibling = sibling.nextElementSibling
    }
    return null
  }

  manualToggle() {
    const menu = this.getMenu()
    if (!menu) return

    const isOpen = menu.classList.contains('show')
    
    if (isOpen) {
      menu.classList.remove('show')
      this.element.setAttribute('aria-expanded', 'false')
    } else {
      // Close other dropdowns first
      document.querySelectorAll('.dropdown-menu.show').forEach(openMenu => {
        if (openMenu !== menu) {
          openMenu.classList.remove('show')
          const toggle = document.querySelector(`[aria-expanded="true"][data-controller="dropdown"]`)
          if (toggle) {
            toggle.setAttribute('aria-expanded', 'false')
          }
        }
      })
      
      menu.classList.add('show')
      this.element.setAttribute('aria-expanded', 'true')
    }
  }

  initializeDropdown() {
    // Wait for Bootstrap to be available
    const initDropdown = () => {
      if (typeof window.bootstrap === 'undefined') {
        setTimeout(initDropdown, 100)
        return
      }

      try {
        // Check if dropdown is already initialized
        this.dropdownInstance = window.bootstrap.Dropdown.getInstance(this.element)
        
        if (!this.dropdownInstance) {
          // Initialize new dropdown
          this.dropdownInstance = new window.bootstrap.Dropdown(this.element, {
            boundary: 'clippingParents',
            display: 'dynamic'
          })
        }
      } catch (error) {
        console.warn('Failed to initialize dropdown:', error)
        this.dropdownInstance = null
      }
    }

    // Try multiple times with increasing delays
    setTimeout(initDropdown, 0)
    setTimeout(initDropdown, 100)
    setTimeout(initDropdown, 300)
  }
}

