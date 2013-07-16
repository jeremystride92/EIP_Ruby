ActiveAdmin.register User do
  controller.skip_authorization_check

  index do
    selectable_column
    column :name
    column :email
    column :venue
    column 'Roles', sortable: false do |user|
      user.roles.map(&:to_s).join ', '
    end
    column :reset_token_date
    actions
  end

end
