# frozen_string_literal: true

class Admin::User::Component::UsersTable < Base::Component::Base
  def initialize(users:, sorting_path: nil)
    @users = users
    @sorting_path = sorting_path || admin_users_path
  end

  def call
    table = Base::Component::Table::Table.new(rows: @users)

    table.add_column(
      header: I18n.t("admin.users.index.table.id"),
      sort_field: :id,
      sort_path: @sorting_path,
      sort_data_type: "number",
    ) do |user|
      "#{user.id}"
    end

    table.add_column(
      header: I18n.t("admin.users.index.table.name"),
      sort_field: :name,
      sort_path: @sorting_path,
      sort_data_type: "string",
      stack: { name: :mobile }
    ) do |user|
      user.name
    end

    table.add_column(
      header: I18n.t("admin.users.index.table.email"),
      sort_field: :email,
      sort_path: @sorting_path,
      sort_data_type: "string",
    ) do |user|
      user.email
    end

    table.add_column(
      header: I18n.t("admin.users.index.table.role"),
      sort_field: :role,
      sort_path: @sorting_path,
      sort_data_type: "string",
      stack: { to: :mobile, prefix: :header, smaller_than: :lg },
      hide: { smaller_than: :md }
    ) do |user|
      role_badge(user.role)
    end

    table.add_column(
      header: I18n.t("admin.users.index.table.company"),
    ) do |user|
      company_name(user) if user.company.present? || user.owned_company.present?
    end

    table.add_column(
      header: I18n.t("admin.users.index.table.created_at"),
      sort_field: :created_at,
      sort_path: @sorting_path,
      sort_data_type: "string",
      hide: { smaller_than: :xl }
    ) do |user|
      table.format_date(user.created_at)
    end

    table.add_column(
      header: I18n.t("admin.users.index.table.actions"),
      type: :button
    ) do |user|
      action_buttons(user)
    end

    render table
  end

  private

  def role_badge(role)
    color_class = case role.to_s
    when "admin"
      "badge bg-danger"
    when "owner"
      "badge bg-primary"
    when "manager"
      "badge bg-info"
    when "employee"
      "badge bg-warning"
    else
      "badge bg-secondary"
    end

    tag.span(I18n.t("roles.#{role}"), class: color_class)
  end

  def company_name(user)
    if user.company.present?
      user.company.name
    elsif user.owned_company.present?
      user.owned_company.name
    else
      tag.span(I18n.t("admin.users.index.table.no_company"), class: "text-muted")
    end
  end

  def action_buttons(user)
    safe_join([
      render(Base::Component::Btn.new(
        type: "show",
        text: I18n.t("admin.users.index.table.view"),
        path: "#",
        size: "xs"
      )),
      render(Base::Component::Btn.new(
        type: "check",
        text: I18n.t("admin.users.index.table.use"),
        path: "#",
        size: "xs"
      )),
      render(Base::Component::Btn.new(
        type: "remove",
        text: I18n.t("admin.users.index.table.delete"),
        path: "#",
        method: :delete,
        data: { confirm: "Are you sure?" },
        size: "xs"
      ))
    ])
  end
end
