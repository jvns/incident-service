class AddStatusToVmInstances < ActiveRecord::Migration[6.0]
  def change
    add_column :vm_instances, :status, :integer, null: false
  end
end
