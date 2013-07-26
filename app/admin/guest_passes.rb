ActiveAdmin.register GuestPass do
  menu parent: 'Card Management'

  controller.skip_authorization_check

  index do
    selectable_column
    column :card
    column :start_date
    column :end_date
    column :created_at
    actions defaults: false do |guest_pass|
      link_to('Delete', resource_path(guest_pass), :method => :delete, :data => {:confirm => I18n.t('active_admin.delete_confirmation')}, :class => "member_link delete_link")
    end
  end
end
