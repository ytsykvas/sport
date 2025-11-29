# frozen_string_literal: true

class Admin::User::Operation::Index < Base::Operation::Base
  def perform!(params:)
    self.model = User.all
  end
end
