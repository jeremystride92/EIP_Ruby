class AddCardsCountToCardLevel < ActiveRecord::Migration
  def up
    add_column :card_levels, :cards_count, :integer, default: 0

    CardLevel.reset_column_information
    CardLevel.all.each do |card_level|
      card_level.update_attribute :cards_count, card_level.cards.length
    end
  end

  def down
    remove_column :card_levels, :cards_count
  end
end
