# frozen_string_literal: true

# Updated: 2025-11-25

class Shared::Navbar::Component::Navbar < ViewComponent::Base
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
    current_path = request.path
    # For admin panel, check both /admin and paths starting with /admin
    if path == "/admin"
      current_path.starts_with?("/admin") ? "active" : ""
    else
      current_path.starts_with?(path) ? "active" : ""
    end
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
