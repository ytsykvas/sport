# frozen_string_literal: true

module Crm
  class CompanyPolicy < BasePolicy
    def create?
      return false unless crm_access?

      user.owner? || user.admin?
    end

    def update?
      return false unless crm_access?

      return true if user.admin?
      return true if user.owner? && record.owner_id == user.id

      false
    end

    def destroy?
      return false unless crm_access?

      return true if user.admin?
      return true if user.owner? && record.owner_id == user.id

      false
    end

    class Scope < BasePolicy::Scope
      def resolve
        return ::Company.none unless crm_access?

        if user.admin?
          scope.all
        elsif user.owner?
          scope.where(owner_id: user.id)
        elsif user.employee? || user.manager?
          user.company_id.present? ? scope.where(id: user.company_id) : ::Company.none
        else
          ::Company.none
        end
      end
    end
  end
end
