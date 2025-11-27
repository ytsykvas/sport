# frozen_string_literal: true

class Crm::Dashboard::Component::Index < Base::Component::Base
  def initialize(user:)
    @dashboard = ::OpenStruct.new(user: user)
  end
end
