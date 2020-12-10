class PuzzlesNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :puzzles, :title, false
    change_column_null :puzzles, :cloud_init, false
  end
end
