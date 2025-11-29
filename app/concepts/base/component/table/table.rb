# frozen_string_literal: true

class Base::Component::Table::Table < ViewComponent::Base
  TableColumn = Struct.new(:header, :sort_field, :sort_path, :align, :type, :stack, :hide, :block, :sort_data_type)

  attr_accessor :order

  def initialize(rows:)
    @rows = rows
    @columns = []
  end

  def add_column(header: nil,
                 align: :start,
                 stack: {},
                 type: :regular,
                 hide: {},
                 sort_field: nil,
                 sort_path: nil,
                 sort_data_type: nil,
                 &block)
    @columns.push(TableColumn.new(header:, sort_field:, sort_path:, sort_data_type:, stack:, align:, type:, block:,
                                  hide:))
  end

  def render_row(row, index, attributes: {})
    render Base::Component::Table::TableRow.new(
      attributes:,
      columns: @columns,
      row:,
      index:
    )
  end

  def column_header(column:)
    return column.header unless column.sort_field.present?

    sorting_link(column: column)
  end

  def format_date(date)
    return "" if date.blank?

    date_value = if date.respond_to?(:to_date)
      date.to_date
    elsif date.is_a?(String)
      Date.parse(date)
    else
      date
    end

    date_value.strftime("%d.%m.%Y")
  end

  private

  def th_class(column:)
    smaller_than = column.stack[:smaller_than] || column.hide[:smaller_than]

    "d-none d-#{smaller_than}-table-cell" if smaller_than
  end

  def sorting_link(column:)
    is_current_column = column.sort_field.to_s == params["sort_by"].to_s

    if is_current_column
      case params["sort_direction"]
      when "desc"
        arrow = tag.i(class: "bi bi-arrow-down sorting-arrow")
        new_direction = "asc"
      when "asc"
        arrow = tag.i(class: "bi bi-arrow-up sorting-arrow")
        new_direction = "desc"
      else
        arrow = tag.i(class: "bi bi-arrow-down sorting-arrow")
        new_direction = "desc"
      end
    else
      arrow = nil
      new_direction = "desc"
    end

    link = link_to(
      column.header,
      "#{column.sort_path}?#{{ sort_by: column.sort_field, sort_direction: new_direction }.to_query}",
      class: "no-decoration-link"
    )

    arrow.present? ? arrow + link : link
  end

  def params
    helpers.params
  end
end
