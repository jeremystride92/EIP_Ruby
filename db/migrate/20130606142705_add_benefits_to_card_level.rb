class AddBenefitsToCardLevel < ActiveRecord::Migration
  def change
    add_column :card_levels, :benefits, :text
  end
end
