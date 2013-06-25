class CreateGuestPasses < ActiveRecord::Migration
  def change
    create_table :guest_passes do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.belongs_to :card

      t.timestamps
    end
    add_index :guest_passes, :card_id
  end
end
