class AddVmTypeToSessions3 < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :ip_address, :string
  end
end
