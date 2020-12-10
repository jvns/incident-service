class RemoveUserEmailFromVmInstances < ActiveRecord::Migration[6.0]
  def change
    remove_column :vm_instances, :user_email, :string
  end
end
