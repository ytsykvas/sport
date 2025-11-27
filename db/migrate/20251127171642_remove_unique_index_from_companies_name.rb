# frozen_string_literal: true

class RemoveUniqueIndexFromCompaniesName < ActiveRecord::Migration[8.1]
  def change
    remove_index :companies, :name
  end
end
