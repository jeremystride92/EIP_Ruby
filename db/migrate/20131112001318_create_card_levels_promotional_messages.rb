class CreateCardLevelsPromotionalMessages < ActiveRecord::Migration
  def change
    create_table :card_levels_promotional_messages do |t|
      t.integer :card_level_id
      t.integer :promotional_message_id
    end
  end
end
