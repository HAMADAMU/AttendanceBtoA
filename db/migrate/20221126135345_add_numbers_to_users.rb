class AddNumbersToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employee_number, :integer, unique: true
    add_column :users, :uid, :integer, unique: true
  end
end
