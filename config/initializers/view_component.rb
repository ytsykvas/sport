# frozen_string_literal: true

Rails.application.config.to_prepare do
  # Configure ViewComponent to use .slim extension
  ViewComponent::Base.config.view_component_path = "app/concepts"
end
