class RemoveDefaultSignupLevelFromCardLevels < ActiveRecord::Migration
  def up
    remove_column :card_levels, :default_signup_level
  end

  def down
    add_column :card_levels, :default_signup_level, :boolean, default: false
  end
end
