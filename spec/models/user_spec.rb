# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string           not null
#  phone                  :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:password).is_at_least(8) }
  end

  describe "devise modules" do
    it "has no public sign-up" do
      expect(User.devise_modules).not_to include(:registerable)
    end
  end

  describe "email" do
    it "is normalized to lowercase without surrounding spaces" do
      user = create(:user, email: "  Jano@Example.COM ")

      expect(user.email).to eq("jano@example.com")
    end

    it "rejects a duplicate that differs only in case" do
      create(:user, email: "jano@example.com")

      expect(build(:user, email: "JANO@example.com")).not_to be_valid
    end
  end

  describe "phone" do
    it "is optional" do
      expect(build(:user, phone: "")).to be_valid
    end

    it "stores a blank phone as nil" do
      expect(create(:user, phone: " ").phone).to be_nil
    end

    it "strips spaces, dashes and parentheses" do
      expect(build(:user, phone: "+421 (901) 234-567").phone).to eq("+421901234567")
    end

    it "turns a 00 prefix into +" do
      expect(build(:user, phone: "00421901234567").phone).to eq("+421901234567")
    end

    it "rejects a number without a country code" do
      user = build(:user, phone: "0901 234 567")

      expect(user).not_to be_valid
      expect(user.errors[:phone]).to be_present
    end

    it "rejects letters" do
      expect(build(:user, phone: "+421abc")).not_to be_valid
    end
  end
end
