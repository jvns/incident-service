class RemoveStartTimeFromVmInstances < ActiveRecord::Migration[6.0]
  def change
    remove_column :vm_instances, :start_time, :integer
  end
end
