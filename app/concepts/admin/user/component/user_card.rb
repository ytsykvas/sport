# frozen_string_literal: true

class Admin::User::Component::UserCard < Base::Component::Base
  def initialize(user:)
    @user = user
  end

  def call
    config = Base::Component::InformationCardConfig.new(
      avatar: @user.name.first.upcase,
      header_title: @user.name,
      header_subtitle: @user.email,
      badge: role_badge(@user.role)
    )

    config.add_section(
      title: I18n.t("admin.users.show.personal_info"),
      type: :grid,
      items: [
        Base::Component::InformationCardConfig.info_item(
          icon: "person",
          label: I18n.t("admin.users.show.name"),
          value: @user.name
        ),
        Base::Component::InformationCardConfig.info_item(
          icon: "envelope",
          label: I18n.t("admin.users.show.email"),
          value: @user.email
        ),
        Base::Component::InformationCardConfig.info_item(
          icon: "shield-check",
          label: I18n.t("admin.users.show.role"),
          value: I18n.t("roles.#{@user.role}")
        ),
        Base::Component::InformationCardConfig.info_item(
          icon: "calendar",
          label: I18n.t("admin.users.show.created_at"),
          value: I18n.l(@user.created_at, format: :long)
        )
      ]
    )

    if @user.company.present? || @user.owned_company.present?
      config.add_section(
        title: I18n.t("admin.users.show.company_info"),
        type: :grid,
        items: [
          Base::Component::InformationCardConfig.info_item(
            icon: "building",
            label: I18n.t("admin.users.show.company_name"),
            value: company_name
          ),
          Base::Component::InformationCardConfig.info_item(
            icon: "person-badge",
            label: I18n.t("admin.users.show.company_role"),
            value: company_role
          )
        ]
      )
    end

    # config.add_section(
    #   title: I18n.t("admin.users.show.actions"),
    #   type: :actions,
    #   items: [
    #     render(Base::Component::Btn.new(
    #       type: "edit",
    #       text: I18n.t("admin.users.show.edit_user"),
    #       path: "#",
    #       size: "M"
    #     )),
    #     render(Base::Component::Btn.new(
    #       type: "remove",
    #       text: I18n.t("admin.users.show.delete_user"),
    #       path: "#",
    #       method: :delete,
    #       data: { confirm: I18n.t("admin.users.show.delete_confirm") },
    #       size: "M"
    #     ))
    #   ]
    # )

    render Base::Component::InformationCard.new(config: config)
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

  def company_name
    if @user.owned_company.present?
      @user.owned_company.name
    elsif @user.company.present?
      @user.company.name
    else
      I18n.t("admin.users.show.no_company")
    end
  end

  def company_role
    if @user.owned_company.present?
      I18n.t("admin.users.show.owner")
    elsif @user.company.present?
      I18n.t("roles.#{@user.role}")
    else
      "-"
    end
  end
end
