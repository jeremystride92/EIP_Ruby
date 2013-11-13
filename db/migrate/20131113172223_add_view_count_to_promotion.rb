class AddViewCountToPromotion < ActiveRecord::Migration
  def change
    add_column :promotions, :view_count, :integer
  end
end
