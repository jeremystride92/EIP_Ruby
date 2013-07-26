ActiveAdmin.register TemporaryCard do
  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(temporary_card: [:phone_number, :partner_id, :issuer_id, :guest_count, :expires_at])
    end

    def resource
      @temporary_card = TemporaryCard.find params[:id]
    end
  end

  filter :venue
  filter :issuer
  filter :partner
  filter :phone_number
  filter :expires_at
  filter :created_at

  index do
    selectable_column
    column :venue
    column :partner
    column :phone_number
    column :guest_count
    column :benefits do |temporary_card|
      ul do
        temporary_card.benefits.each do |benefit|
          li benefit.description
        end
      end
    end
    column :created_at
    column :expires_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :phone_number
      f.input :guest_count
      f.input :partner, collection: temporary_card.try(:venue).try(:partners) || Partner.all, group_by: :venue
      f.input :issuer, collection: temporary_card.try(:venue).try(:users) || User.all, group_by: :venue
      f.input :expires_at
    end
    f.actions
  end

  show do |temporary_card|
    attributes_table do
      row :phone_number
      row :guest_count
      row :benefits do
        ul do
          temporary_card.benefits.each do |benefit|
            li benefit.description
          end
        end
      end
      row :partner
      row :issuer
      row :expires_at
      row :created_at
    end
  end
end
