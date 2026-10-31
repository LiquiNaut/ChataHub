require "rails_helper"

RSpec.describe "Rate limiting", type: :request do
  let(:message) { "Príliš veľa pokusov. Skús to znova o pár minút." }

  describe "login" do
    def attempt
      post user_session_path, params: { user: { email: "jano@example.com", password: "zle-heslo" } }
    end

    it "allows 10 attempts from one IP" do
      10.times { attempt }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "blocks the 11th attempt within 3 minutes" do
      11.times { attempt }

      expect(response).to have_http_status(:too_many_requests)
      expect(response.body).to include(message)
    end

    it "blocks even the correct password once limited" do
      user = create(:user, password: "heslo-na-chatu")
      10.times { attempt }

      post user_session_path, params: { user: { email: user.email, password: "heslo-na-chatu" } }

      expect(response).to have_http_status(:too_many_requests)
    end

    it "allows attempts again after 3 minutes" do
      11.times { attempt }

      travel 3.minutes + 1.second do
        attempt
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it "does not limit opening the login page" do
      11.times { get new_user_session_path }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "password reset" do
    def attempt
      post user_password_path, params: { user: { email: "jano@example.com" } }
    end

    it "blocks the 6th request within 15 minutes" do
      5.times { attempt }
      expect(response).to have_http_status(:see_other)

      attempt

      expect(response).to have_http_status(:too_many_requests)
      expect(response.body).to include(message)
    end
  end
end
