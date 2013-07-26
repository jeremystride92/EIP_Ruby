class CreateTemporaryCards < ActiveRecord::Migration
  def change
    create_table :temporary_cards do |t|
      t.string :phone_number
      t.belongs_to :partner
      t.integer :issuer_id
      t.integer :guest_count
      t.string :access_token
      t.datetime :expires_at

      t.timestamps
    end
    add_index :temporary_cards, :partner_id
  end
end
