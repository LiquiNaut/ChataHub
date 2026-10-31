require "rails_helper"

RSpec.describe "Invitations", type: :request do
  let(:owner) { create(:user, :owner) }
  let(:admin) { create(:user, :admin) }
  let(:invite_params) { { user: { email: "teta@example.com", name: "Teta Anka" } } }

  def last_invitation_token
    ActionMailer::Base.deliveries.last.html_part.body.to_s[/invitation_token=([^"&]+)/, 1]
  end

  describe "sending" do
    it "is forbidden for a member" do
      sign_in create(:user)

      get new_user_invitation_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Na toto nemáš oprávnenie.")
    end

    it "redirects a guest to the login page" do
      get new_user_invitation_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "shows the form without a role picker to an owner" do
      sign_in owner

      get new_user_invitation_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("user[role]")
    end

    it "shows the role picker to an admin" do
      sign_in admin

      get new_user_invitation_path

      expect(response.body).to include("user[role]")
    end

    it "lets an owner invite a member" do
      sign_in owner

      expect {
        post user_invitation_path, params: invite_params
      }.to change(User, :count).by(1).and change { ActionMailer::Base.deliveries.size }.by(1)

      invited = User.find_by!(email: "teta@example.com")
      expect(invited).to be_member
      expect(invited.name).to eq("Teta Anka")
      expect(invited.invitation_accepted?).to be(false)
      expect(flash[:notice]).to eq("Pozvánka odišla na teta@example.com.")
    end

    it "forbids an owner from inviting an admin" do
      sign_in owner

      expect {
        post user_invitation_path, params: { user: invite_params[:user].merge(role: "admin") }
      }.not_to change(User, :count)

      expect(flash[:alert]).to eq("Na toto nemáš oprávnenie.")
    end

    it "lets an admin invite an owner" do
      sign_in admin

      post user_invitation_path, params: { user: invite_params[:user].merge(role: "owner") }

      expect(User.find_by!(email: "teta@example.com")).to be_owner
    end

    it "requires a name" do
      sign_in owner

      expect {
        post user_invitation_path, params: { user: { email: "teta@example.com", name: "" } }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "sends nothing to an email that already has an account" do
      sign_in owner
      create(:user, email: "teta@example.com")

      expect {
        post user_invitation_path, params: invite_params
      }.not_to change { ActionMailer::Base.deliveries.size }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "resends a pending invitation without a second account" do
      sign_in owner
      post user_invitation_path, params: invite_params

      expect {
        post user_invitation_path, params: invite_params
      }.to change { ActionMailer::Base.deliveries.size }.by(1).and not_change(User, :count)
    end
  end

  describe "accepting" do
    before do
      sign_in owner
      post user_invitation_path, params: invite_params
      sign_out owner
    end

    let(:token) { last_invitation_token }
    let(:accept_params) do
      { user: { invitation_token: token, name: "Anka", phone: "+421 905 111 222",
                password: "heslo-na-chatu", password_confirmation: "heslo-na-chatu" } }
    end

    it "sends a Slovak email with the accept link" do
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq("Pozvánka do ChataHubu")
      expect(mail.text_part.body.to_s).to include("Teta Anka")
      expect(mail.text_part.body.to_s).to include(7.days.from_now.strftime("%-d. %-m. %Y"))
      expect(token).to be_present
    end

    it "does not let the invitee log in before accepting" do
      post user_session_path, params: { user: { email: "teta@example.com", password: "whatever-123" } }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "shows the accept form with the name prefilled" do
      get accept_user_invitation_path(invitation_token: token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Teta Anka")
    end

    it "sets the password and signs the invitee in" do
      put user_invitation_path, params: accept_params

      expect(response).to redirect_to(root_path)
      user = User.find_by!(email: "teta@example.com")
      expect(user.name).to eq("Anka")
      expect(user.phone).to eq("+421905111222")
      expect(user.valid_password?("heslo-na-chatu")).to be(true)
      expect(user.invitation_accepted?).to be(true)
    end

    it "does not accept the same link twice" do
      put user_invitation_path, params: accept_params
      sign_out User.find_by!(email: "teta@example.com")

      get accept_user_invitation_path(invitation_token: token)

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Odkaz na pozvánku je neplatný alebo vypršal. Požiadaj toho, kto ťa pozval, o novú.")
    end

    it "rejects an expired invitation" do
      travel 8.days do
        get accept_user_invitation_path(invitation_token: token)
      end

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to include("vypršal")
    end
  end
end
