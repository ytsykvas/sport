# frozen_string_literal: true

class Admin::User::Operation::Index < Base::Operation::Base
  include Base::Operation::Sortable

  def perform!(params:, current_user:)
    self.model = ::OpenStruct.new(users: nil)

    users = policy_scope(User)

    users = apply_sorting(
      users,
      params: params,
      allowed_columns: %i[id name email role created_at],
      default_column: :id,
      default_direction: :desc
    )

    self.model.users = users
  end
end
