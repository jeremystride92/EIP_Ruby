class AddDailyGuestPassCountToCardLevel < ActiveRecord::Migration
  def change
    add_column :card_levels, :daily_guest_pass_count, :integer, default: 0
  end
end
