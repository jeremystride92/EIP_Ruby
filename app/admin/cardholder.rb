ActiveAdmin.register Cardholder do
  controller.skip_authorization_check

  controller do
    def permitted_params
      params.permit(cardholder: [:phone_number, :first_name, :last_name, :status])
    end
  end

  menu :priority => 2

  filter :venues
  filter :status, as: :select, collection: Cardholder::STATUSES
  filter :phone_number
  filter :first_name
  filter :last_name

  index do
    selectable_column
    column :photo do |cardholder|
      image_tag cardholder.photo.url, class: 'avatar-thumb'
    end
    column :phone_number
    column :first_name
    column :last_name
    column :status
    column :activated_at
    column :created_at
    actions
  end

  show do |cardholder|
    attributes_table do
      row :photo do
        image_tag(cardholder.photo)
      end
      row :phone_number
      row :first_name
      row :last_name
      row :status
      row :onboarding_token
      row :activated_at
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Cardholder Details" do
      f.input :phone_number
      f.input :first_name
      f.input :last_name
      f.input :status, collection: Cardholder::STATUSES
      f.input :photo
    end
    f.actions
  end
end
