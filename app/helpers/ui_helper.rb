module UiHelper
  BUTTON_BASE = "inline-flex min-h-11 items-center justify-center gap-2 rounded-xl px-5 text-[15px] font-semibold " \
                "transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent " \
                "disabled:cursor-not-allowed disabled:bg-disabled disabled:text-muted".freeze

  BUTTON_VARIANTS = {
    primary: "bg-primary text-primary-ink font-bold hover:brightness-95",
    secondary: "border border-line bg-surface text-ink hover:bg-subtle",
    ghost: "bg-transparent px-3 text-accent hover:bg-subtle",
    danger: "bg-danger text-danger-ink hover:brightness-95"
  }.freeze

  BADGE_TONES = {
    paid: "bg-mine text-mine-ink",
    unpaid: "bg-warning text-warning-ink",
    no_show: "bg-occupied text-occupied-ink",
    neutral: "border border-line text-muted"
  }.freeze

  def ui_button_classes(variant = :primary, block: false)
    class_names(BUTTON_BASE, BUTTON_VARIANTS.fetch(variant), "w-full": block)
  end

  def ui_badge(text, tone: :neutral)
    tag.span(text, class: class_names("inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold",
                                      BADGE_TONES.fetch(tone)))
  end
end
