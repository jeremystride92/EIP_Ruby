ActiveAdmin.register CardTheme do
  menu parent: 'Venue Management'

  controller.skip_authorization_check

  controller do
    def permitted_params
      params.permit(card_theme: [:venue_id, :name, :portrait_background, :portrait_background_cache, :landscape_background, :landscape_background_cache])
    end
  end

  filter :venues
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :venue
    column :name
    actions
  end

  show do |card_theme|
    attributes_table do
      row :venue
      row :name
      row :portrait_background do
        image_tag card_theme.portrait_background
      end
      row :landscape_background do
        image_tag card_theme.landscape_background
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :venue
      f.input :name
      f.input :portrait_background
      f.input :landscape_background
    end

    f.actions
  end
end
