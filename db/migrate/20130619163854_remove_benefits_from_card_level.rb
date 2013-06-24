class RemoveBenefitsFromCardLevel < ActiveRecord::Migration
  def up
    remove_column :card_levels, :benefits
  end

  def down
    add_column :card_levels, :benefits, :text
  end
end
