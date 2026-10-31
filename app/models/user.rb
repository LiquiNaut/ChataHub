# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string           not null
#  phone                  :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  PHONE_FORMAT = /\A\+[1-9]\d{7,14}\z/

  # No :registerable, accounts come from invitations
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  normalizes :phone, with: ->(phone) { phone.gsub(/[\s\-()]/, "").sub(/\A00/, "+").presence }

  validates :name, presence: true
  validates :phone, format: { with: PHONE_FORMAT }, allow_nil: true
end
