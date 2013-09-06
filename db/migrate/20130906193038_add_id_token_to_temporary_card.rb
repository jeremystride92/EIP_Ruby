class AddIdTokenToTemporaryCard < ActiveRecord::Migration
  def change
    add_column :temporary_cards, :id_token, :string
  end
end
