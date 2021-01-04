class RenameInstancesSessions < ActiveRecord::Migration[6.0]
  def change
    rename_table :vm_instances, :sessions
  end
end
