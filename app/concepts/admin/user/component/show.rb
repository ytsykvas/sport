# frozen_string_literal: true

class Admin::User::Component::Show < Base::Component::Base
  def initialize(user:)
    @user = user
  end
end
