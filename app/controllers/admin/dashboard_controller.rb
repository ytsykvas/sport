# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      endpoint Admin::Dashboard::Operation::Index, Admin::Dashboard::Component::Index
    end
  end
end
