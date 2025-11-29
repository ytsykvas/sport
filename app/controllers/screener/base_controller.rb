# frozen_string_literal: true

module Screener
  class BaseController < ApplicationController
    layout "screener"

    before_action :authorize_screener_access

    private

    def authorize_screener_access
      user = current_user
      policy = Screener::BasePolicy.new(user, nil)
      raise Pundit::NotAuthorizedError, policy: policy, query: :index? unless policy.index?
    end
  end
end
