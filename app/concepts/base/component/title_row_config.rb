# frozen_string_literal: true

class Base::Component::TitleRowConfig
  attr_accessor :title, :back_path, :back_text, :divider

  def initialize(
    title: nil,
    back_path: nil,
    back_text: nil,
    divider: false
  )
    @title = title
    @back_path = back_path
    @back_text = back_text
    @divider = divider
  end
end
