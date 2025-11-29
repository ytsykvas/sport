# frozen_string_literal: true

class Base::Component::Table::TableRow < ViewComponent::Base
  def initialize(columns:, row:, index:, attributes: {})
    @attributes = attributes
    @columns = columns
    @row = row
    @index = index
  end

  def render_td(row:, column:)
    content = capture do
      concat cell_content(row:, column:)
      concat stack_content(row:, column:)
    end

    if column.type == :button
      return tag.td(class: "text-end align-middle td-button") do
        tag.div(class: "d-flex flex-row flex-wrap gap-2 align-items-center justify-content-end",
                style: "margin-top: -7px; margin-bottom: -7px; flex-direction: row !important;") do
          content
        end
      end
    end

    class_list = []
    smaller_than = column.stack[:smaller_than] || column.hide[:smaller_than]
    class_list.push("d-none", "d-#{smaller_than}-table-cell") if smaller_than

    tag.td(content, class: class_list.compact.join(" "))
  end

  def cell_content(row:, column:)
    column.block.call(ensure_object(row))
  end

  def stack_content(row:, column:)
    return "" unless column.stack.key? :name

    source_columns = @columns.select { |source_column| source_column.stack[:to] == column.stack[:name] }

    tag.dl(class: "m-0") do
      capture do
        source_columns.each do |source_column|
          prefix = if source_column.stack[:prefix] == :header
                     source_column.header
          else
                     source_column.stack[:prefix]
          end

          str = cell_content(column: source_column, row:)

          if str.present?
            concat tag.dd([ prefix, str ].compact.join(": ").html_safe,
                          class: "m-0 d-#{source_column.stack[:smaller_than]}-none")
          end
        end
      end
    end
  end

  def row_id(row:, index:)
    if row.respond_to? :hashid
      row.hashid
    else
      index
    end
  end

  private

  def ensure_object(row)
    row.is_a?(Hash) ? ::OpenStruct.new(row) : row
  end
end
