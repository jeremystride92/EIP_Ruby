class AddActivatedAtToCardholders < ActiveRecord::Migration
  def change
    add_column :cardholders, :activated_at, :datetime
  end
end
