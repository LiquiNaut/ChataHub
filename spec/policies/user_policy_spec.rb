require "rails_helper"

RSpec.describe UserPolicy do
  subject { described_class }

  let(:member) { build_stubbed(:user) }
  let(:owner) { build_stubbed(:user, :owner) }
  let(:admin) { build_stubbed(:user, :admin) }
  let(:other) { build_stubbed(:user) }

  permissions :update_role? do
    it "lets an admin change someone else's role" do
      expect(subject).to permit(admin, other)
      expect(subject).to permit(admin, build_stubbed(:user, :admin))
    end

    it "denies an admin changing their own role" do
      expect(subject).not_to permit(admin, admin)
    end

    it "denies owners and members" do
      expect(subject).not_to permit(owner, other)
      expect(subject).not_to permit(member, other)
    end
  end
end
