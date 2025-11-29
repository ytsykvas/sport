# frozen_string_literal: true

module Crm
  class BasePolicy < ApplicationPolicy
    def index?
      crm_access?
    end

    def show?
      crm_access?
    end

    def create?
      crm_access?
    end

    def update?
      crm_access?
    end

    def destroy?
      crm_access?
    end

    private

    def crm_access?
      return false unless user

      user.admin? || user.owner? || user.employee? || user.manager?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless crm_access?

        scope.all
      end

      private

      def crm_access?
        return false unless user

        user.admin? || user.owner? || user.employee? || user.manager?
      end
    end
  end
end
