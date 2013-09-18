ActiveAdmin.register CardLevel do
  menu parent: 'Venue Management'

  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(card_level: [:venue_id, :name, :card_theme_id, :daily_redeemable_benefit_allotment])
    end
  end

  filter :venue
  filter :name
  filter :card_theme_id
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :venue
    column :name
    column :card_theme do |card_level|
      card_level.card_theme.try :name
    end
    column :daily_redeemable_benefit_allotment
    actions
  end

  form do |f|
    f.inputs do
      f.input :venue
      f.input :name
      f.input :card_theme, as: :select, collection: card_level.venue.card_themes
      f.input :daily_redeemable_benefit_allotment
    end
    f.actions
  end
end
