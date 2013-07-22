ActiveAdmin.register Card do
  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(card: [:card_level_id, :cardholder_id, :issuer_id, :status])
    end
  end

  index do
    selectable_column
    column :card_level
    column :cardholder
    column :benefits do |card|
      ul do
        card.benefits.each do |benefit|
          li benefit.description
        end
      end
    end
    column :status
    column :issuer
    column :issued_at
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :card_level, collection: card.venue.card_levels
      f.input :cardholder
      f.input :issuer
      f.input :status, collection: Card::STATUSES
    end
    f.actions
  end

end
