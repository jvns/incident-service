class CreatePuzzles < ActiveRecord::Migration[6.0]
  def change
    create_table :puzzles do |t|
      t.string :title
      t.text :cloud_init

      t.timestamps
    end
  end
end
