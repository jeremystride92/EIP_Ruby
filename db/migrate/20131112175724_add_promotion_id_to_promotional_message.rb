class AddPromotionIdToPromotionalMessage < ActiveRecord::Migration
  def change
    add_column :promotional_messages, :promotion_id, :integer
  end
end
