class RenameSessionsDigitalOceanId3 < ActiveRecord::Migration[6.0]
  def change
    rename_column :sessions, :digitalocean_id, :vm_id
    change_column_null :sessions, :vm_type, false
  end
end
