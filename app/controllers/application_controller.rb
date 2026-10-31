class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization

  before_action :authenticate_user!
  after_action :verify_authorized, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    redirect_back_or_to root_path, alert: "Na toto nemáš oprávnenie."
  end

  # Skip root, keeps the signed-out notice
  def after_sign_out_path_for(_scope)
    new_user_session_path
  end
end
