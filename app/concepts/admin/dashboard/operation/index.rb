# frozen_string_literal: true

class Admin::Dashboard::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    self.model = ::OpenStruct.new(users: nil, companies: nil, admins: nil)

    self.model.users = policy_scope(User)
    self.model.companies = policy_scope(Company)
    self.model.admins = self.model.users.admin
  end
end
