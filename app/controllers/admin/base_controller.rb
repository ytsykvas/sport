# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :authorize_admin_access

    private

    def authorize_admin_access
      user = current_user
      policy = Admin::BasePolicy.new(user, nil)
      raise Pundit::NotAuthorizedError, policy: policy, query: :index? unless policy.index?
    end
  end
end
