# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include OperationsMethods

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s

    if policy_name == "Crm::BasePolicy"
      # User tried to access CRM but doesn't have permission
      # If they're logged in and are business users, show error
      # Otherwise redirect to screener
      if current_user && (current_user.owner? || current_user.employee? || current_user.manager?)
        flash[:alert] = "У вас немає доступу до цього розділу."
        redirect_to crm_root_path
      else
        redirect_to root_path
      end
    elsif policy_name == "Screener::BasePolicy"
      # User tried to access Screener but doesn't have permission (business users)
      # Redirect them to CRM
      redirect_to crm_root_path
    else
      flash[:alert] = "У вас немає доступу до цієї дії."
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
