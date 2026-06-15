# == Schema Information
#
# Table name: cabins
#
#  id              :bigint           not null, primary key
#  capacity        :integer
#  location        :string
#  name            :string
#  price_per_night :decimal(, )
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryBot.define do
  factory :cabin do
  end
end
