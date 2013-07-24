class CreatePartners < ActiveRecord::Migration
  def change
    create_table :partners do |t|
      t.string :name
      t.string :phone_number
      t.belongs_to :venue

      t.timestamps
    end
    add_index :partners, :venue_id
  end
end
