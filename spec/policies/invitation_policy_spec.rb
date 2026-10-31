require "rails_helper"

RSpec.describe InvitationPolicy do
  subject { described_class }

  let(:member) { build_stubbed(:user) }
  let(:owner) { build_stubbed(:user, :owner) }
  let(:admin) { build_stubbed(:user, :admin) }

  permissions :new?, :create? do
    it "lets owners and admins invite" do
      expect(subject).to permit(owner, :invitation)
      expect(subject).to permit(admin, :invitation)
    end

    it "denies members" do
      expect(subject).not_to permit(member, :invitation)
    end
  end

  describe "#assignable_roles" do
    it "lets an admin pick any role" do
      expect(described_class.new(admin, :invitation).assignable_roles).to eq(%w[member owner admin])
    end

    it "limits an owner to members" do
      expect(described_class.new(owner, :invitation).assignable_roles).to eq(%w[member])
    end

    it "gives a member nothing" do
      expect(described_class.new(member, :invitation).assignable_roles).to be_empty
    end
  end
end
