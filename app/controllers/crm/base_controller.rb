# frozen_string_literal: true

module Crm
  class BaseController < ApplicationController
    layout "crm"

    before_action :authorize_crm_access

    private

    def authorize_crm_access
      user = current_user
      policy = Crm::BasePolicy.new(user, nil)
      raise Pundit::NotAuthorizedError, policy: policy, query: :index? unless policy.index?
    end
  end
end
