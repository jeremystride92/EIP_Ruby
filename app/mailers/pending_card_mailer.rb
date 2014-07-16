class PendingCardMailer < ActionMailer::Base
  default from: ENV['site_email']

  def pending_card_email(card_class, card_id, venue_admin_id)
    card = card_class.constantize.find(card_id)
    venue_admin = User.find(venue_admin_id)
    @phone_number = card.phone_number

    mail to: venue_admin.email,
         subject: "Pending Card Request for #{@phone_number}"
  end
end