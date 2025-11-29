# frozen_string_literal: true

class Crm::Company::Operation::Edit < Base::Operation::Base
  def perform!(params:, current_user:)
    companies = policy_scope(Company)
    company = companies.first

    authorize! company, :update? if company.present?

    self.model = ::OpenStruct.new(company: company)
  end
end
