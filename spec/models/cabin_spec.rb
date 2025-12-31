# == Schema Information
#
# Table name: cabins
#
#  id              :integer          not null, primary key
#  name            :string
#  price_per_night :decimal(, )
#  capacity        :integer
#  location        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Cabin, type: :model do
  describe "validations" do
    subject { described_class.new(
      name: "Ondrášová",
      price_per_night: 5.00,
      capacity: 10,
      location: "Veľké Uherce, Ondrášová"
    )}

    it "has valid attributes" do
      expect(subject).to be_valid
    end

    # it "is not valid without a name" do
    #   should validate_presence_of(:name)
    # end

    # Name
    it { should validate_presence_of(:name) }

    # it 'is not valid without a price per night' do
    #   subject.price_per_night = nil
    #   expect(subject).to_not be_valid
    # end

    # Price_per_night
    it { should validate_presence_of(:price_per_night) }

    # it 'is not valid with negative price per night' do
    #   subject.price_per_night = -10
    #   expect(subject).to_not be_valid
    # end

    it { should validate_numericality_of(:price_per_night).is_greater_than(0) }

    # it 'price per night is numerical' do
    #   subject.price_per_night = "abc"
    #   expect(subject).to_not be_valid
    # end

    # Capacity
    it { should validate_presence_of(:capacity) }

    it { should validate_numericality_of(:capacity).is_greater_than(0) }

    it { should validate_numericality_of(:capacity).only_integer }

    # Location tests
    it { should validate_presence_of(:location) }
  end
end
