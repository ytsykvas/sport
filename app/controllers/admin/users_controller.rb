# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  def index
    endpoint Admin::User::Operation::Index, Admin::User::Component::Index
  end

  def show
    endpoint Admin::User::Operation::Show, Admin::User::Component::Show
  end
end
