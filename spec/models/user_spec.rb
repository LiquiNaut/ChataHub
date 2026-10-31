# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  name                   :string           not null
#  phone                  :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("member"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :bigint
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invited_by            (invited_by_type,invited_by_id)
#  index_users_on_invited_by_id         (invited_by_id)
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

  describe "role" do
    it { should define_enum_for(:role).with_values(member: 0, owner: 1, admin: 2).validating }

    it "defaults to member" do
      expect(User.new).to be_member
    end

    it "keeps at least one admin" do
      admin = create(:user, :admin)

      admin.role = :owner

      expect(admin).not_to be_valid
      expect(admin.errors[:role]).to include("posledný admin nemôže prísť o rolu")
    end

    it "allows demoting an admin when another one remains" do
      create(:user, :admin)
      admin = create(:user, :admin)

      expect(admin.update(role: :member)).to be(true)
    end
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
