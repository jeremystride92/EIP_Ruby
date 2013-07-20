class AddIssuedAtToCards < ActiveRecord::Migration
  def change
    add_column :cards, :issued_at, :datetime
  end
end
