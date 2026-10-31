require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject { described_class }

  let(:admin) { build(:user, :admin) }

  permissions :index?, :show?, :create?, :new?, :update?, :edit?, :destroy? do
    it "denies everything by default, even to an admin" do
      expect(subject).not_to permit(admin, Object.new)
    end
  end

  it "forces each policy to define its own scope" do
    expect { described_class::Scope.new(admin, User).resolve }.to raise_error(NoMethodError)
  end
end
