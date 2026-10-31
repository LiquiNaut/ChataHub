module Users
  class PasswordsController < Devise::PasswordsController
    include AuthRateLimited

    rate_limit to: 5, within: 15.minutes, only: :create, with: -> { render_rate_limited }
  end
end
