class AddVenueToUser < ActiveRecord::Migration
  def up
    add_column :users, :venue_id, :integer

    Venue.all.each do |venue|
      u = User.find(venue.owner_id).tap { |u| u.venue = venue }.save!
    end

    remove_column :venues, :owner_id
  end


  def down
    add_column :venues, :owner_id, :integer

    Venue.all.each do |venue|
      owner = User.where(venue: venue).select(&:venue_owner?).first
      venue.owner = owner
    end

    remove_column :users, :venue
  end
end
