class VmInstancesNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :vm_instances, :digitalocean_id, false
    change_column_null :vm_instances, :user_email, false
    change_column_null :vm_instances, :proxy_id, false
    change_column_null :vm_instances, :puzzle_id, false

    add_foreign_key :vm_instances, :puzzles
    add_foreign_key :vm_instances, :users, column: 'user_email', primary_key: 'email'

  end
end
