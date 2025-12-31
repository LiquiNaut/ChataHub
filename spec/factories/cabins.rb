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

FactoryBot.define do
  factory :cabin do
  end
end
