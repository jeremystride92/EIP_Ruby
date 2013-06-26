class AddDefaultSignupLevelToCardLevel < ActiveRecord::Migration
  def up
    add_column :card_levels, :default_signup_level, :boolean, default: 'false'
    Venue.all.each do |venue|
      card_level = venue.card_levels.first
      if card_level
        puts "setting #{card_level.name} to default for venue #{venue.name}"
        card_level.update_attribute(:default_signup_level, true)
      end
    end
  end

  def down
    remove_column :card_levels, :default_signup_level
  end
end
