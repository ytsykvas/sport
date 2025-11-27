# frozen_string_literal: true

class Shared::Sidebar::Component::Sidebar < ViewComponent::Base
  def initialize(current_user: nil)
    @current_user = current_user
  end

  def signed_in?
    @current_user.present?
  end

  def user_name
    @current_user&.name || @current_user&.email&.split("@")&.first
  end

  def active_nav_class(path)
    request.path.starts_with?(path) ? "active" : ""
  end

  def admin?
    @current_user&.admin?
  end

  def owner?
    @current_user&.owner?
  end

  def company_name
    @current_user&.company&.name || @current_user&.owned_company&.name
  end
end
