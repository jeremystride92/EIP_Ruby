class AddCardThemeToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :card_theme_id, :integer
  end
end
