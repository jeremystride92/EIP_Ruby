ActiveAdmin.register Partner do
  menu parent: 'EIP-X'
  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(partner: [:venue_id, :name, :phone_number, :redeemable_benefit_name])
    end
  end

  index do
    selectable_column
    column :venue
    column :name
    column :phone_number
    column :redeemable_benefit_name
    column :active_cards_count
    column :lifetime_cards_count
    column :created_at
    column :updated_at
    actions
  end

  show do |partner|
    attributes_table do
      row :venue
      row :name
      row :phone_number
      row :redeemable_benefit_name
      row :active_cards_count
      row :lifetime_cards_count
      row :created_at
      row :updated_at
    end
  end
end
