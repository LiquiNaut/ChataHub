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
#  role                   :integer          default(0), not null
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

  enum :role, { member: 0, owner: 1, admin: 2 }, default: :member, validate: true

  normalizes :phone, with: ->(phone) { phone.gsub(/[\s\-()]/, "").sub(/\A00/, "+").presence }

  validates :name, presence: true
  validates :phone, format: { with: PHONE_FORMAT }, allow_nil: true
  validate :keeps_an_admin, if: -> { role_changed? && role_was == "admin" }

  private

  def keeps_an_admin
    errors.add(:role, "posledný admin nemôže prísť o rolu") unless User.admin.where.not(id:).exists?
  end
end
