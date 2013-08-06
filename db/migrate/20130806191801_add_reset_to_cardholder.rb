class AddResetToCardholder < ActiveRecord::Migration
  def change
    add_column :cardholders, :reset_token, :string
    add_column :cardholders, :reset_token_date, :datetime
  end
end
