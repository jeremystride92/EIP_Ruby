class AddOwnerToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :owner_id, :integer
  end
end
