ActiveAdmin.register TemporaryCard do
  menu parent: 'EIP-X'
  controller.skip_authorization_check
  controller do
    def permitted_params
      params.permit(temporary_card: [:phone_number, :partner_id, :issuer_id, :redeemable_benefit_allotment, :expires_at])
    end

    def resource
      @temporary_card = TemporaryCard.find params[:id]
    end
  end

  batch_action :resend_sms_to do |selection|
    TemporaryCard.find(selection).each do |card|
      # PK Edit
      # SmsMailer.delay(retry: false).temp_card_sms(card.id, card.venue.id, card.partner.id)
      SmsMailer.temp_card_sms(card.id, card.venue.id, card.partner.id)
    end
    redirect_to :back, notice: "#{selection.length} #{'message'.pluralize(selection.length)} queued for delivery"
  end

  member_action :resend_sms, method: :post do
    card = TemporaryCard.find(params[:id])

    # PK Edit
    # SmsMailer.delay(retry: false).temp_card_sms(card.id, card.venue.id, card.partner.id)
    SmsMailer.temp_card_sms(card.id, card.venue.id, card.partner.id)
    
    redirect_to :back, notice: "Message to #{card.phone_number} queued for delivery"
  end

  action_item :only => :show do
    link_to('Resend SMS', resend_sms_admin_temporary_card_path(temporary_card), method: :post)
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
    column :redeemable_benefit_allotment
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
      f.input :redeemable_benefit_allotment
      f.input :partner, collection: temporary_card.try(:venue).try(:partners) || Partner.all, group_by: :venue
      f.input :issuer, collection: temporary_card.try(:venue).try(:users) || User.all, group_by: :venue
      f.input :expires_at
    end
    f.actions
  end

  show do |temporary_card|
    attributes_table do
      row :phone_number
      row :redeemable_benefit_allotment
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
