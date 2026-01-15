import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "slider", "value"];

  connect() {
    this.submitTimer = null;
    this.syncValues();
  }

  onInput() {
    this.syncValues();

    if (this.submitTimer) clearTimeout(this.submitTimer);
    this.submitTimer = setTimeout(() => {
      this.formTarget.requestSubmit();
    }, 200);
  }

  syncValues() {
    this.sliderTargets.forEach((slider, i) => {
      const v = this.valueTargets[i];
      if (v) v.textContent = slider.value;
    });
  }
}
