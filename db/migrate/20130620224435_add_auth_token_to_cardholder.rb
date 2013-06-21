class AddAuthTokenToCardholder < ActiveRecord::Migration
  def change
    add_column :cardholders, :auth_token, :string
  end
end
