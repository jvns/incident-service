class DropPuzzles < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key "puzzle_statuses", "puzzles"
    remove_foreign_key "sessions", "puzzles"
    drop_table :puzzles

  end
end
