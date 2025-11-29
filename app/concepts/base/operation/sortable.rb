# frozen_string_literal: true

module Base::Operation::Sortable
  extend ActiveSupport::Concern

  private

  def apply_sorting(relation, params:, allowed_columns:, default_column: :id, default_direction: :desc)
    if params[:sort_by].present?
      sort_column = params[:sort_by].to_sym
      sort_direction = params[:sort_direction] == "asc" ? :asc : :desc

      if allowed_columns.include?(sort_column)
        relation.order(sort_column => sort_direction)
      else
        relation.order(default_column => default_direction)
      end
    else
      relation.order(default_column => default_direction)
    end
  end
end
