class AddStatusToPuzzles < ActiveRecord::Migration[6.0]
  def change
    add_column :puzzles, :published, :boolean
    change_column :puzzles, :published, :boolean, :default => false
  end
end
