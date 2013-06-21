class AddSecurePasswordToCardholders < ActiveRecord::Migration
  def change
    add_column :cardholders, :password_digest, :string
  end
end
