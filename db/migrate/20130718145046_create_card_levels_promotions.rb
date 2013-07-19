class CreateCardLevelsPromotions < ActiveRecord::Migration
  def change
    create_table :card_levels_promotions, id: false do |t|
      t.references :card_level, null: false
      t.references :promotion, null: false
    end

    add_index :card_levels_promotions, :card_level_id
    add_index :card_levels_promotions, :promotion_id
  end
end
