ActiveAdmin.register Card do
  menu parent: 'Card Management'

  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(card: [:card_level_id, :cardholder_id, :issuer_id, :status])
    end

    def resource
      @card = Card.find params[:id]
    end
  end

  batch_action :'activate/deactivate' do |selection|
    activated = 0
    deactivated = 0
    Card.find(selection).each do |card|
      next if card.pending?
      if card.active?
        card.update_attributes(status: 'inactive')
        deactivated += 1
      else
        card.update_attributes(status: 'active')
        activated += 1
      end
    end
    helpers = ActionController::Base.helpers
    redirect_to :back, notice: "#{helpers.pluralize(activated, 'card')} activated, #{helpers.pluralize(deactivated, 'card')} deactivated"
  end

  index do
    selectable_column
    column :card_level
    column :cardholder
    column :benefits do |card|
      ul do
        card.benefits.each do |benefit|
          li do
            desc = benefit.description
            desc << " from #{l benefit.start_date, format: :very_short}" if benefit.start_date
            desc << " until #{l benefit.end_date, format: :very_short}" if benefit.end_date
            desc
          end
        end
      end
    end
    column :status
    column :issuer
    column :issued_at
    column :created_at
    actions
  end

  show do |card|
    attributes_table do
      row :card_level
      row :cardholder
      row :benefits do
        ul do
          card.benefits.each do |benefit|
            li do
              desc = benefit.description
              desc << " from #{l benefit.start_date, format: :friendly}" if benefit.start_date
              desc << " until #{l benefit.end_date, format: :friendly}" if benefit.end_date
              desc
            end
          end
        end
      end
      row :status
      row :issuer
      row :issued_at
      row :created_at
    end
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
