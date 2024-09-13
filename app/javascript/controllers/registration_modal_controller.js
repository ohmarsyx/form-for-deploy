import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="registration-modal"
export default class extends Controller {
  static targets = ["registrationModal"];
  connect() {
    console.log("Connect to registration stimulus");
  }

  open() {
    console.log("open modal");
    console.log(this.registrationModalTarget);
    this.registrationModalTarget.style.display = "flex";
  }
  close() {
    console.log("close modal");
    this.registrationModalTarget.style.display = "none";
  }
}
