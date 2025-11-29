# frozen_string_literal: true

class Admin::Dashboard::Component::Index < Base::Component::Base
  def initialize(users:, companies:, admins:)
    @users = users
    @companies = companies
    @admins = admins
  end

  def users_count
    @users.count
  end

  def companies_count
    @companies.count
  end

  def admins_count
    @admins.count
  end
end
