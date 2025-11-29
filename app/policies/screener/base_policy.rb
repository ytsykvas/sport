# frozen_string_literal: true

module Screener
  class BasePolicy < ApplicationPolicy
    def index?
      screener_access?
    end

    def show?
      screener_access?
    end

    def create?
      screener_access?
    end

    def update?
      screener_access?
    end

    def destroy?
      screener_access?
    end

    private

    def screener_access?
      user.nil? || user.customer? || user.admin?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.all if screener_access?

        scope.none
      end

      private

      def screener_access?
        user.nil? || user.customer? || user.admin?
      end
    end
  end
end
