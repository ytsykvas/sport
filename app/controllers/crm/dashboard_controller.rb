# frozen_string_literal: true

class Crm::DashboardController < Crm::BaseController
  def index
    endpoint Crm::Dashboard::Operation::Index, Crm::Dashboard::Component::Index
  end
end
