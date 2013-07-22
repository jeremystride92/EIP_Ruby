ActiveAdmin.register Cardholder do
  controller.skip_authorization_check

  controller do
    def permitted_params
      params.permit(cardholder: [:phone_number, :first_name, :last_name, :status, :photo, :photo_cache])
    end
  end

  batch_action :send_activation_messages_to do |selection|
    Cardholder.find(selection).each do |cardholder|
      cardholder.generate_onboarding_token
      cardholder.save
      SmsMailer.delay(retry: false).cardholder_onboarding_sms(cardholder, nil)
    end
    redirect_to :back, notice: "Messages queued for sending"
  end

  member_action :send_activation_message, method: :post do
    cardholder = Cardholder.find(params[:id])
    cardholder.generate_onboarding_token
    cardholder.save
    SmsMailer.delay(retry: false).cardholder_onboarding_sms(cardholder, nil)
    redirect_to :back, notice: "Message to #{cardholder.phone_number} queued for sending"
  end

  action_item :only => :show do
    link_to('Send Activation Message', send_activation_message_admin_cardholder_path(cardholder), method: :post)
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
      f.input :photo_cache, as: :hidden
    end
    f.actions
  end
end
