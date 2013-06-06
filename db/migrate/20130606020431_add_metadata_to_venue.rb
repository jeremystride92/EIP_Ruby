class AddMetadataToVenue < ActiveRecord::Migration
  def change
    add_column :venues, :phone, :string
    add_column :venues, :location, :string
    add_column :venues, :address1, :string
    add_column :venues, :address2, :string
    add_column :venues, :website, :string
    add_column :venues, :vanity_slug, :string
  end
end
