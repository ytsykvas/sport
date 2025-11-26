class AddForeignKeyToUsers < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :users, :companies, column: :company_id
    add_foreign_key :companies, :users, column: :owner_id
  end
end
