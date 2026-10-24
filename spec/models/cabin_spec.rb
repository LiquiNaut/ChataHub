# == Schema Information
#
# Table name: cabins
#
#  id                    :bigint           not null, primary key
#  capacity              :integer          not null
#  location              :string           not null
#  name                  :string           not null
#  price_per_night_cents :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'rails_helper'

RSpec.describe Cabin, type: :model do
  subject { build(:cabin) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }

    it { should validate_presence_of(:capacity) }
    it { should validate_numericality_of(:capacity).only_integer.is_greater_than(0) }

    it { should validate_presence_of(:price_per_night_cents) }
    it { should validate_numericality_of(:price_per_night_cents).only_integer.is_greater_than(0) }
  end

  describe "database columns" do
    it { should have_db_column(:name).of_type(:string).with_options(null: false) }
    it { should have_db_column(:location).of_type(:string).with_options(null: false) }
    it { should have_db_column(:capacity).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:price_per_night_cents).of_type(:integer).with_options(null: false) }
    it { should_not have_db_column(:price_per_night) }
  end
end
