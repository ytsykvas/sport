# frozen_string_literal: true

class Admin::User::Component::Index < Base::Component::Base
  def initialize(users:)
    @users = users
  end
end
