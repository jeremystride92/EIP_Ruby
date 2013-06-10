class AddRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :roles_mask, :integer
  end
end
