ActiveAdmin.register Venue do
  menu :priority => 1

  filter :name
  filter :phone
  filter :location
  filter :address1
  filter :address2
  filter :website
  filter :vanity_slug
  filter :timezone

  index do
    selectable_column
    column :name
    column :location
    column 'Address', sortable: :address1 do |venue|
      "#{venue.address1}; #{venue.address2}"
    end
    column :phone
    column :website
    column :vanity_slug
    actions
  end

  index as: :grid do |venue|
    render 'admin/venue_grid_cell', venue: venue
  end

  show do |venue|
    attributes_table do
      row :logo do
        image_tag(venue.logo)
      end
      row :name
      row :location
      row :address1
      row :address2
      row :phone
      row :website do
        link_to venue.website.to_s
      end
      row :vanity_slug
      row :timezone
      row :card_levels do
        ul do
          venue.card_levels.each do |card_level|
            li card_level.name
          end
        end
      end
    end
  end
end
