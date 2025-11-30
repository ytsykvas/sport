# frozen_string_literal: true

class Base::Component::InformationCard < Base::Component::Base
  def initialize(config: nil, **)
    @config = config || Base::Component::InformationCardConfig.new(**)
  end

  def call
    tag.div(class: "information-card") do
      safe_join([
        render_header,
        render_body
      ].compact)
    end
  end

  private

  def render_header
    return unless @config.header_title || @config.header_subtitle || @config.avatar

    tag.div(class: "information-card-header") do
      safe_join([
        render_avatar,
        render_header_content
      ].compact)
    end
  end

  def render_avatar
    return unless @config.avatar

    tag.div(class: "information-card-avatar") do
      tag.div(class: "avatar-circle") do
        if @config.avatar.is_a?(String)
          tag.span(@config.avatar)
        else
          @config.avatar
        end
      end
    end
  end

  def render_header_content
    return unless @config.header_title || @config.header_subtitle || @config.badge

    tag.div(class: "information-card-title") do
      safe_join([
        @config.header_title ? tag.h2(@config.header_title, class: "card-name") : nil,
        @config.header_subtitle ? tag.p(@config.header_subtitle, class: "card-subtitle") : nil,
        @config.badge
      ].compact)
    end
  end

  def render_body
    tag.div(class: "information-card-body") do
      safe_join(@config.sections.map { |section| render_section(section) })
    end
  end

  def render_section(section)
    tag.div(class: "info-section") do
      safe_join([
        render_section_title(section[:title]),
        render_section_content(section)
      ].compact)
    end
  end

  def render_section_title(title)
    return unless title

    tag.h3(title, class: "section-title")
  end

  def render_section_content(section)
    case section[:type]
    when :grid
      render_grid_section(section[:items])
    when :actions
      render_actions_section(section[:items])
    when :custom
      section[:content]
    else
      render_grid_section(section[:items])
    end
  end

  def render_grid_section(items)
    return unless items

    tag.div(class: "info-grid") do
      safe_join(items.map { |item| render_info_item(item) })
    end
  end

  def render_actions_section(items)
    return unless items

    tag.div(class: "actions-grid") do
      safe_join(items)
    end
  end

  def render_info_item(item)
    tag.div(class: "info-item") do
      safe_join([
        render_info_icon(item[:icon]),
        render_info_content(item)
      ].compact)
    end
  end

  def render_info_icon(icon)
    return unless icon

    tag.div(class: "info-icon") do
      tag.i(class: "bi bi-#{icon}")
    end
  end

  def render_info_content(item)
    tag.div(class: "info-content") do
      safe_join([
        item[:label] ? tag.div(item[:label], class: "info-label") : nil,
        item[:value] ? tag.div(item[:value], class: "info-value") : nil
      ].compact)
    end
  end
end
