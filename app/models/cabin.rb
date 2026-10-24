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

class Cabin < ApplicationRecord
  validates :name, :location, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :price_per_night_cents, presence: true, numericality: { greater_than: 0, only_integer: true }
end
