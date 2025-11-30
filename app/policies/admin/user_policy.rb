# frozen_string_literal: true

module Admin
  class UserPolicy < BasePolicy
    def show?
      admin_access?
    end

    class Scope < BasePolicy::Scope
      def resolve
        return scope.none unless admin_access?

        scope.all
      end
    end
  end
end
