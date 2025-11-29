# frozen_string_literal: true

class Crm::Company::Component::Edit < Base::Component::Base
  def initialize(company:)
    @company = company
  end
end
