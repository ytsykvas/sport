# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s

    if policy_name == "CrmPolicy"
      redirect_to root_path
    elsif policy_name == "ScreenerPolicy"
      redirect_to crm_root_path
    else
      flash[:alert] = "You are not authorized to perform this action."
      redirect_back(fallback_location: root_path)
    end
  end

  allow_browser versions: :modern

  helper_method :current_user

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :role, :register_company, :company_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :role ])
  end
end
