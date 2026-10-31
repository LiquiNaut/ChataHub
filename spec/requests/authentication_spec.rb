require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let!(:user) { create(:user, email: "jano@example.com", password: "heslo-na-chatu") }

  describe "guest" do
    it "is redirected to the login page" do
      get root_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "can open the login page" do
      get new_user_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Prihlásiť sa")
    end

    it "has no sign-up route" do
      get "/users/sign_up"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "login" do
    it "signs in with valid credentials" do
      post user_session_path, params: { user: { email: user.email, password: "heslo-na-chatu" } }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include(user.name)
    end

    it "accepts the email in a different case with spaces" do
      post user_session_path, params: { user: { email: "  JANO@example.com ", password: "heslo-na-chatu" } }

      expect(response).to redirect_to(root_path)
    end

    it "rejects a wrong password" do
      post user_session_path, params: { user: { email: user.email, password: "zle-heslo" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Nesprávny e-mail alebo heslo.")
    end

    it "gives the same message for an unknown email" do
      post user_session_path, params: { user: { email: "nikto@example.com", password: "zle-heslo" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Nesprávny e-mail alebo heslo.")
    end
  end

  describe "logout" do
    it "signs the user out" do
      sign_in user

      delete destroy_user_session_path
      expect(response).to redirect_to(new_user_session_path)
      follow_redirect!
      expect(response.body).to include("Si odhlásený.")

      get root_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "password reset" do
    let(:paranoid_notice) { "Ak e-mail patrí k účtu, do pár minút ti príde odkaz na zmenu hesla." }

    it "sends reset instructions to an existing user" do
      expect {
        post user_password_path, params: { user: { email: user.email } }
      }.to change { ActionMailer::Base.deliveries.size }.by(1)

      follow_redirect!
      expect(response.body).to include(paranoid_notice)
    end

    it "shows the same notice for an unknown email" do
      expect {
        post user_password_path, params: { user: { email: "nikto@example.com" } }
      }.not_to change { ActionMailer::Base.deliveries.size }

      follow_redirect!
      expect(response.body).to include(paranoid_notice)
    end

    it "changes the password with a valid token" do
      token = user.send_reset_password_instructions

      put user_password_path, params: {
        user: { reset_password_token: token, password: "nove-heslo-123", password_confirmation: "nove-heslo-123" }
      }

      expect(user.reload.valid_password?("nove-heslo-123")).to be(true)
    end
  end
end
