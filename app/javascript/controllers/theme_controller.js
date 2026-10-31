import { Controller } from "@hotwired/stimulus"

// Light / dark / system theme switch
export default class extends Controller {
  static targets = ["option", "sun", "moon"]

  connect() {
    this.sync = () => this.render(this.current)
    window.addEventListener("theme:changed", this.sync)
    this.render(this.current)
  }

  disconnect() {
    window.removeEventListener("theme:changed", this.sync)
  }

  select(event) {
    this.apply(event.params.theme)
  }

  toggle() {
    this.apply(this.effective === "dark" ? "light" : "dark")
  }

  apply(theme) {
    try {
      if (theme === "system") localStorage.removeItem("theme")
      else localStorage.setItem("theme", theme)
    } catch (e) {}

    if (theme === "system") delete document.documentElement.dataset.theme
    else document.documentElement.dataset.theme = theme

    // Keep other switchers on the page in sync
    window.dispatchEvent(new CustomEvent("theme:changed"))
  }

  render(theme) {
    this.optionTargets.forEach((option) => {
      option.setAttribute("aria-checked", option.dataset.themeThemeParam === theme)
    })

    const dark = this.effective === "dark"
    this.sunTargets.forEach((icon) => icon.hidden = !dark)
    this.moonTargets.forEach((icon) => icon.hidden = dark)
    if (this.sunTargets.length) {
      this.element.setAttribute("aria-label", dark ? "Prepnúť na svetlý režim" : "Prepnúť na tmavý režim")
    }
  }

  get current() {
    return document.documentElement.dataset.theme || "system"
  }

  get effective() {
    if (this.current !== "system") return this.current
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }
}
