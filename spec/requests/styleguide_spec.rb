require "rails_helper"

RSpec.describe "Styleguide", type: :request do
  it "renders the design system page" do
    get styleguide_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Dizajn systém")
  end

  it "shows the theme switcher" do
    get styleguide_path

    expect(response.body).to include('data-controller="theme"')
  end
end
