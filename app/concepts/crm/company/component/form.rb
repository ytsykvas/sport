# frozen_string_literal: true

class Crm::Company::Component::Form < Base::Component::Base
  def initialize(company:)
    @company = company
  end
end
