class AddDeletedAtToCardLevel < ActiveRecord::Migration
  def change
    add_column :card_levels, :deleted_at, :datetime
  end
end
