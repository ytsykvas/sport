# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include OperationsMethods

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s

    if policy_name == "Admin::BasePolicy"
      # User tried to access Admin but doesn't have permission
      flash[:alert] = I18n.t("authorization.admin_access_denied")
      if current_user
        # Redirect based on user role
        if current_user.owner? || current_user.employee? || current_user.manager?
          redirect_to crm_root_path
        else
          redirect_to root_path
        end
      else
        redirect_to root_path
      end
    elsif policy_name == "Crm::BasePolicy"
      if current_user && (current_user.owner? || current_user.employee? || current_user.manager?)
        flash[:alert] = I18n.t("authorization.crm_access_denied")
        redirect_to crm_root_path
      else
        redirect_to root_path
      end
    elsif policy_name == "Screener::BasePolicy"
      redirect_to crm_root_path
    else
      flash[:alert] = I18n.t("authorization.action_access_denied")
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
