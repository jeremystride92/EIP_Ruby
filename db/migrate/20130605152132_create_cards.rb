class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :card_level
      t.references :cardholder

      t.timestamps
    end
    add_index :cards, :card_level_id
    add_index :cards, :cardholder_id
  end
end
