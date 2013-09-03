class RemoveCardCounterCacheFromCardLevel < ActiveRecord::Migration
  def up
    remove_column :card_levels, :cards_count
  end

  def down
    add_column :card_levels, :cards_count, :integer, default: 0
  end
end
