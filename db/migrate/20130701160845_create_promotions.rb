class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.string :image
      t.belongs_to :venue

      t.timestamps
    end
    add_index :promotions, :venue_id
  end
end
