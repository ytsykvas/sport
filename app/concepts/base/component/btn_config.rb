# frozen_string_literal: true

class Base::Component::BtnConfig
  attr_reader :type, :text, :path, :disabled, :modal_target, :submit, :method, :data, :size, :prefetch, :target,
              :formaction

  def initialize(
    type: nil, text: nil, path: nil, disabled: false,
    modal_target: nil, submit: false, method: nil, data: {}, size: "sm", prefetch: nil, target: nil, formaction: nil
  )
    @type = type
    @text = text
    @path = path
    @disabled = disabled
    @modal_target = modal_target
    @submit = submit
    @method = method
    @data = data
    @size = size
    @prefetch = prefetch
    @target = target
    @formaction = formaction
  end

  def to_h
    {
      type: @type,
      text: @text,
      path: @path,
      disabled: @disabled,
      modal_target: @modal_target,
      submit: @submit,
      method: @method,
      data: @data,
      size: @size,
      prefetch: @prefetch,
      target: @target,
      formaction: @formaction
    }
  end
end
