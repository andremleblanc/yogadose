class ApplicationController < ActionController::Base
  include Pundit
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def after_sign_in_path_for(resource)
    current_user.active? ? dashboard_path : new_subscription_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def user_not_authorized
    #TODO: Track this
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referrer || dashboard_path)
  end
end
