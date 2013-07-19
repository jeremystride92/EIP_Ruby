class AddSortPositionToCardLevel < ActiveRecord::Migration
  def change
    add_column :card_levels, :sort_position, :integer
  end
end
