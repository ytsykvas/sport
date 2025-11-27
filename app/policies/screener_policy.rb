class ScreenerPolicy < ApplicationPolicy
  def access?
    user.nil? || user.customer? || user.admin?
  end
end
