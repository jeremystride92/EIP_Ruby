class CreateCardLevels < ActiveRecord::Migration
  def change
    create_table :card_levels do |t|
      t.string :name
      t.references :venue

      t.timestamps
    end
    add_index :card_levels, :venue_id
  end
end
