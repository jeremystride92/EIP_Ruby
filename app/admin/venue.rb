ActiveAdmin.register Venue do
  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(venue: [:phone, :name, :logo, :location, :address1, :address2, :website, :vanity_slug, :time_zone, :nexmo_number])
    end
  end
  menu parent: 'Venue Management', priority: 1

  filter :name
  filter :phone
  filter :nexmo_number
  filter :location
  filter :address1
  filter :address2
  filter :website
  filter :vanity_slug

  index do
    selectable_column
    column :name
    column :location
    column 'Address', sortable: :address1 do |venue|
      "#{venue.address1}; #{venue.address2}"
    end
    column :phone
    column :nexmo_number
    column :website
    column :vanity_slug
    column :time_zone, label_method: :to_s, value_method: :name
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
      row :nexmo_number
      row :website do
        link_to venue.website.to_s
      end
      row :vanity_slug
      row :time_zone
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
