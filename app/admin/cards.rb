ActiveAdmin.register Card do
  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(card: [:card_level_id, :cardholder_id, :issuer_id, :status])
    end

    def resource
      @card = Card.find params[:id]
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
      f.input :card_level, collection: card.try(:venue).try(:card_levels) || CardLevel.all, group_by: :venue
      f.input :cardholder
      f.input :issuer, collection: card.try(:venue).try(:users) || User.all, group_by: :venue
      f.input :status, collection: Card::STATUSES
    end
    f.actions
  end

end
