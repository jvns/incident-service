class CreatePuzzleStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :puzzle_statuses do |t|
      t.integer :user_id, null: false
      t.integer :puzzle_id, null: false
      t.boolean :finished, null: false

      t.timestamps
    end
  end
end
