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

FactoryBot.define do
  factory :cabin do
    name { "Ondrášová" }
    location { "Veľké Uherce, Ondrášová" }
    capacity { 10 }
    price_per_night_cents { 500 }
  end
end
