# frozen_string_literal: true

class Base::Component::TitleRow < Base::Component::Base
  def initialize(config: nil, **)
    @config = config || Base::Component::TitleRowConfig.new(**)
  end

  def call
    tag.div(class: "mb-4") do
      safe_join([
        render_back_button,
        render_title,
        render_divider
      ].compact)
    end
  end

  private

  def render_back_button
    return unless @config.back_path

    link_to @config.back_path, class: "btn btn-outline btn-sm" do
      safe_join([
        tag.i(class: "bi bi-arrow-left me-2"),
        tag.span(@config.back_text)
      ])
    end
  end

  def render_title
    return unless @config.title

    tag.h1(@config.title, class: "mt-3 mb-0")
  end

  def render_divider
    return unless @config.divider

    tag.hr
  end
end
