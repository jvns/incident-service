class AddPuzzleStatusForeignKey < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key "puzzle_statuses", "users"
    add_foreign_key "puzzle_statuses", "puzzles"
  end
end
