import { Controller } from "@hotwired/stimulus"

// Light / dark / system theme switch
export default class extends Controller {
  static targets = ["option"]

  connect() {
    this.render(this.current)
  }

  select(event) {
    const theme = event.params.theme

    try {
      if (theme === "system") localStorage.removeItem("theme")
      else localStorage.setItem("theme", theme)
    } catch (e) {}

    if (theme === "system") delete document.documentElement.dataset.theme
    else document.documentElement.dataset.theme = theme

    this.render(theme)
  }

  render(theme) {
    this.optionTargets.forEach((option) => {
      option.setAttribute("aria-checked", option.dataset.themeThemeParam === theme)
    })
  }

  get current() {
    return document.documentElement.dataset.theme || "system"
  }
}
