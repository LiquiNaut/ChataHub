require "rails_helper"

RSpec.describe "Authorization", type: :request do
  let(:forbidden_controller) do
    Class.new(ApplicationController) do
      def show
        authorize User.new, :update_role?
        head :ok
      end
    end
  end

  before do
    stub_const("ForbiddenController", forbidden_controller)
    sign_in create(:user)
  end

  it "redirects with an alert when the policy denies the action" do
    with_routing do |routes|
      routes.draw do
        devise_for :users
        root "home#show"
        get "forbidden" => "forbidden#show"
      end

      get "/forbidden"

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Na toto nemáš oprávnenie.")
    end
  end
end
