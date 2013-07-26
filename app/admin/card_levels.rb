ActiveAdmin.register CardLevel do
  menu parent: 'Venue Management'
  
  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(card_level: [:venue_id, :name, :theme, :daily_guest_pass_count])
    end
  end

  filter :venue
  filter :name
  filter :theme, as: :select, collection: CardLevel::THEMES
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :venue
    column :name
    column :theme
    column :daily_guest_pass_count
    actions
  end

  form do |f|
    f.inputs do
      f.input :venue
      f.input :name
      f.input :theme, collection: CardLevel::THEMES
      f.input :daily_guest_pass_count
    end
    f.actions
  end
end
