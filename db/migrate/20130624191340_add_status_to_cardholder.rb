class AddStatusToCardholder < ActiveRecord::Migration
  def change
    add_column :cardholders, :status, :string
  end
end
