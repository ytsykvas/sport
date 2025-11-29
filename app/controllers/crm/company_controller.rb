# frozen_string_literal: true

class Crm::CompanyController < Crm::BaseController
  def edit
    endpoint Crm::Company::Operation::Edit, Crm::Company::Component::Edit
  end
end
