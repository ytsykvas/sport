# frozen_string_literal: true

class Admin::User::Operation::Show < Base::Operation::Base
  def perform!(params:, current_user:)
    user = User.find(params[:id])
    authorize! user, :show?

    self.model = ::OpenStruct.new(user: user)
  end
end
