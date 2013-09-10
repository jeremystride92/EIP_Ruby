class RemoveThemeFromCardLevel < ActiveRecord::Migration
  def up
    remove_column :card_levels, :theme
  end

  def down
    add_column :card_levels, :theme, :string
  end
end
