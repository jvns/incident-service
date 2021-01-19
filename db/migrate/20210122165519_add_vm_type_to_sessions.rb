class AddVmTypeToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :vm_type, :integer
  end
end
