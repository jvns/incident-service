class CreateVmInstances < ActiveRecord::Migration[6.0]
  def change
    create_table :vm_instances do |t|
      t.string :digitalocean_id
      t.string :user_email
      t.string :proxy_id
      t.integer :start_time
      t.integer :puzzle_id

      t.timestamps
    end
  end
end
