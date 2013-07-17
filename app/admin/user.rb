ActiveAdmin.register User do
  controller.skip_authorization_check
  menu priority: 1

  controller do
    def permitted_params
      params.permit(:user => [:name, :venue_id, :email, :password, :password_confirmation, :roles])
    end
  end

  filter :venues
  filter :email
  filter :name
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :name
    column :email
    column :venue
    column 'Roles', sortable: false do |user|
      user.roles.map(&:to_s).map(&:humanize).join ', '
    end
    actions
  end

  form html: {novalidate: false} do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :venue, required: true, input_html: { required:true }
      f.input :email
      f.input :roles, collection: User.valid_roles, required: true, input_html: { required:true }
    end
    f.actions
  end

  show do |user|
    attributes_table do
      row :name
      row :email
      row :venue
      row :roles do
        user.roles.map(&:to_s).map(&:humanize).join ', '
      end
    end
  end
end
