ActiveAdmin.register Cardholder do
  controller.skip_authorization_check
  menu :priority => 2

  filter :venues
  filter :status, as: :select, collection: Cardholder::STATUSES
  filter :phone_number
  filter :first_name
  filter :last_name

  index do
    selectable_column
    column :phone_number
    column :first_name
    column :last_name
    column :status
    actions
  end

  form do |f|
    f.inputs "Cardholder Details" do
      f.input :phone_number
      f.input :first_name
      f.input :last_name
      f.input :status, collection: Cardholder::STATUSES
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
