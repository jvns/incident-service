class AddPortToVmInstances < ActiveRecord::Migration[6.0]
  def change
    add_column :vm_instances, :gotty_port, :integer, null: false
  end
end
