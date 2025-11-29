# frozen_string_literal: true

class Base::Component::Btn < ViewComponent::Base
  VALID_TYPES = %w[add cancel check edit next save search show remove].freeze

  def initialize(config: nil, **)
    @config = config || Base::Component::BtnConfig.new(**)
  end

  def call
    if @config.path.present?
      tag.a(
        href: @config.path,
        class: button_classes,
        disabled: @config.disabled,
        data: button_data,
        target: @config.target,
        style: "white-space: nowrap; text-decoration: none;"
      ) do
        tag.span(class: "d-inline-flex align-items-center") do
          safe_join([ icon_tag, tag.span(@config.text, class: "ms-2 btn-text") ])
        end
      end
    else
      tag.button(
        class: button_classes,
        disabled: @config.disabled,
        data: button_data,
        type: @config.submit ? "submit" : "button",
        formaction: @config.formaction,
        style: "white-space: nowrap;"
      ) do
        tag.span(class: "d-inline-flex align-items-center") do
          safe_join([ icon_tag, tag.span(@config.text, class: "ms-2 btn-text") ])
        end
      end
    end
  end

  private

  def button_classes
    classes = %w[btn]

    case @config.type
    when "remove"
      classes << "btn-danger"
    when "show", "edit"
      classes << "btn-outline"
    else
      classes << "btn-primary"
    end

    if @config.size.to_s == "xs"
      classes << "btn-xs"
    elsif @config.size.to_s == "sm" || @config.size.blank?
      classes << "btn-sm"
    end

    classes << "disabled" if @config.disabled
    classes.join(" ")
  end

  def button_data
    data = @config.data.dup
    data["method"] = @config.method if @config.method.present?

    configure_turbo_prefetch(data)
    configure_modal_data(data) if @config.modal_target
    data["turbo"] = false if disable_turbo_types.include?(@config.type)

    data
  end

  def configure_turbo_prefetch(data)
    if @config.type == "remove"
      data["turbo_prefetch"] = false
    elsif !@config.prefetch.nil?
      data["turbo_prefetch"] = @config.prefetch
    elsif @config.path.present? && @config.method.blank?
      data["turbo_prefetch"] = true
    end
  end

  def configure_modal_data(data)
    data.merge!(
      "bs-toggle": "modal",
      "bs-target": "##{@config.modal_target}"
    )
  end

  def icon_tag
    return unless @config.type && VALID_TYPES.include?(@config.type)

    tag.i(class: "bi bi-#{icon_mapping[@config.type]} btn-icon flex-shrink-0")
  end

  def text_tag
    return if @config.text.blank?

    tag.span(@config.text, class: "ms-2 btn-text")
  end

  def icon_mapping
    {
      "add" => "plus-circle",
      "cancel" => "x-circle",
      "check" => "check-circle",
      "edit" => "pencil",
      "next" => "arrow-right-circle",
      "save" => "save",
      "search" => "search",
      "show" => "eye",
      "remove" => "trash"
    }
  end

  def disable_turbo_types
    %w[check next remove save search]
  end
end
