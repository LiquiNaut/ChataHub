require "rails_helper"

RSpec.describe UiHelper, type: :helper do
  describe "#ui_button_classes" do
    it "uses the primary variant by default" do
      expect(helper.ui_button_classes).to include("bg-primary", "text-primary-ink", "min-h-11")
    end

    it "returns the classes of the given variant" do
      expect(helper.ui_button_classes(:danger)).to include("bg-danger", "text-danger-ink")
      expect(helper.ui_button_classes(:danger)).not_to include("bg-primary")
    end

    it "stretches to full width when block" do
      expect(helper.ui_button_classes(:secondary, block: true)).to include("w-full")
      expect(helper.ui_button_classes(:secondary)).not_to include("w-full")
    end

    it "raises for an unknown variant" do
      expect { helper.ui_button_classes(:fancy) }.to raise_error(KeyError)
    end
  end

  describe "#ui_badge" do
    it "renders the text with the tone colors" do
      html = Capybara.string(helper.ui_badge("Zaplatené", tone: :paid))

      expect(html).to have_css("span.bg-mine.text-mine-ink", text: "Zaplatené")
    end

    it "falls back to the neutral tone" do
      html = Capybara.string(helper.ui_badge("Zrušená"))

      expect(html).to have_css("span.text-muted", text: "Zrušená")
    end
  end
end
