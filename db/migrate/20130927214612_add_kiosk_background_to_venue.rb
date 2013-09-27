class AddKioskBackgroundToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :kiosk_background, :string
  end
end
