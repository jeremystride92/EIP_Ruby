class AddThemeToCardLevel < ActiveRecord::Migration
  def change
    add_column :card_levels, :theme, :string
  end
end
