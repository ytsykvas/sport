# frozen_string_literal: true

class Shared::Sidebar::Component::AdminSidebar < Base::Component::Base
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
    # For dashboard, check both /admin and /admin/dashboard
    if path == "/admin/dashboard"
      (current_path == "/admin" || current_path.starts_with?("/admin/dashboard")) ? "active" : ""
    else
      current_path.starts_with?(path) ? "active" : ""
    end
  end
end
