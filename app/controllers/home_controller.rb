class HomeController < ApplicationController
  # Placeholder page, nothing to authorize
  skip_after_action :verify_authorized

  def show
  end
end
