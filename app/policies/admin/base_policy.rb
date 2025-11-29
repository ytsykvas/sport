# frozen_string_literal: true

module Admin
  class BasePolicy < ApplicationPolicy
    def index?
      admin_access?
    end

    def show?
      admin_access?
    end

    def create?
      admin_access?
    end

    def update?
      admin_access?
    end

    def destroy?
      admin_access?
    end

    private

    def admin_access?
      return false unless user

      user.admin?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless admin_access?

        scope.all
      end

      private

      def admin_access?
        return false unless user

        user.admin?
      end
    end
  end
end
