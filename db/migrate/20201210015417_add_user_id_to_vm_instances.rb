class AddUserIdToVmInstances < ActiveRecord::Migration[6.0]
  def change
    add_column :vm_instances, :user_id, :integer, null: false
    add_foreign_key "vm_instances", "users"
  end
end
