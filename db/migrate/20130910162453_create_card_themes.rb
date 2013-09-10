class CreateCardThemes < ActiveRecord::Migration
  def change
    create_table :card_themes do |t|
      t.string :name
      t.belongs_to :venue
      t.string :portrait_background
      t.string :landscape_background

      t.timestamps
    end
    add_index :card_themes, :venue_id
  end
end
