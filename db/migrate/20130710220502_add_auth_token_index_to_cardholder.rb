class AddAuthTokenIndexToCardholder < ActiveRecord::Migration
  def change
    add_index :cardholders, :auth_token
  end
end
