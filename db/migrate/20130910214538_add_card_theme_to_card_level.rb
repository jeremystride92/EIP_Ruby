class AddCardThemeToCardLevel < ActiveRecord::Migration
  def change
    add_column :card_levels, :card_theme_id, :integer
  end
end
