# frozen_string_literal: true

module Crm
  class BaseController < ApplicationController
    layout "crm"

    before_action :authorize_crm_access

    private

    def authorize_crm_access
      authorize :crm, :access?
    end
  end
end
