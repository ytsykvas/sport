class CrmPolicy < ApplicationPolicy
  def access?
    return false unless user

    user.admin? || user.owner? || user.employee? || user.manager?
  end
end
