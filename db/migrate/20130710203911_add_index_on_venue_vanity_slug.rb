class AddIndexOnVenueVanitySlug < ActiveRecord::Migration
  def change
    add_index :venues, :vanity_slug
  end
end
