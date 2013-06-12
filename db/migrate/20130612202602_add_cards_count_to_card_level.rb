class AddCardsCountToCardLevel < ActiveRecord::Migration
  def up
    add_column :card_levels, :cards_count, :integer, default: 0

    CardLevel.reset_column_information
    CardLevel.find_each do |card_level|
      CardLevel.reset_counters card_level.id, :cards
    end
  end

  def down
    remove_column :card_levels, :cards_count
  end
end
