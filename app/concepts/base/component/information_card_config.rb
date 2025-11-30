# frozen_string_literal: true

class Base::Component::InformationCardConfig
  attr_accessor :avatar, :header_title, :header_subtitle, :badge, :sections

  def initialize(
    avatar: nil,
    header_title: nil,
    header_subtitle: nil,
    badge: nil,
    sections: []
  )
    @avatar = avatar
    @header_title = header_title
    @header_subtitle = header_subtitle
    @badge = badge
    @sections = sections
  end

  # Helper method to add a section
  def add_section(title: nil, type: :grid, items: [], content: nil)
    @sections << {
      title: title,
      type: type,
      items: items,
      content: content
    }
  end

  # Helper method to create info item
  def self.info_item(icon:, label:, value:)
    {
      icon: icon,
      label: label,
      value: value
    }
  end
end
