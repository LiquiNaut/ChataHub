module Users
  class SessionsController < Devise::SessionsController
    include AuthRateLimited

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render_rate_limited }
  end
end
