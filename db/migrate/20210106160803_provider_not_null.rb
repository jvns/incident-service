class ProviderNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :users, :provider, false
    change_column_null :users, :uid, false
  end
end
