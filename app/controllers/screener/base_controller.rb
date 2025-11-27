# frozen_string_literal: true

module Screener
  class BaseController < ApplicationController
    layout "screener"

    before_action :authorize_screener_access

    private

    def authorize_screener_access
      authorize :screener, :access?
    end
  end
end
