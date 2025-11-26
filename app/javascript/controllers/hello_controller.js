import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.textContent = "Hello from Stimulus!"
    console.log("HelloController connected")
  }
}
