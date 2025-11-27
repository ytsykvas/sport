# frozen_string_literal: true

class Crm::Dashboard::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    self.model = ::OpenStruct.new(user: current_user)
  end
end
