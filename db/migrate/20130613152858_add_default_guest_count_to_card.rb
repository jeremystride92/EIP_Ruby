class AddDefaultGuestCountToCard < ActiveRecord::Migration
  def up
    change_column :cards, :guest_count, :integer, default: 0
  end

  def down
    change_column :cards, :guest_count, :integer, default: nil
  end
end
