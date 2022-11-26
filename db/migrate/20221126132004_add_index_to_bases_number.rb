class AddIndexToBasesNumber < ActiveRecord::Migration[5.1]
  def change
    add_index :bases, :number, unique: true
  end
end
