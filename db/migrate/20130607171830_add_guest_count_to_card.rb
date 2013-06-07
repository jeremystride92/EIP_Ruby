class AddGuestCountToCard < ActiveRecord::Migration
  def change
    add_column :cards, :guest_count, :integer
  end
end
