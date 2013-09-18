ActiveAdmin.register RedeemableBenefit do
  menu parent: 'Card Management'

  controller.skip_authorization_check

  index do
    selectable_column
    column :card
    column :start_date
    column :end_date
    column :created_at
    actions defaults: false do |redeemable_benefit|
      link_to('Delete', resource_path(redeemable_benefit), :method => :delete, :data => {:confirm => I18n.t('active_admin.delete_confirmation')}, :class => "member_link delete_link")
    end
  end
end
