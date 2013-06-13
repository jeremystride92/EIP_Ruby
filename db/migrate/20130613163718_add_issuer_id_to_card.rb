class AddIssuerIdToCard < ActiveRecord::Migration
  def change
    add_column :cards, :issuer_id, :integer
  end
end
