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

class Cabin < ApplicationRecord
  validates :name, presence: true
  validates :price_per_night, presence: true, numericality: { greater_than: 0 }
  validates :capacity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :location, presence: true, numericality: false
end
