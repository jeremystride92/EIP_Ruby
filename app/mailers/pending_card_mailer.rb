class PendingCardMailer < ActionMailer::Base
  default from: ENV['site_email']

  def pending_card_email(card_id, venue_admin_id)
    card = Card.find(card_id)
    venue_admin = User.find(venue_admin_id)

    @cardholder = card.cardholder

    mail to: venue_admin.email,
         subject: "Pending Card Request for #{@cardholder.display_name}"
  end
end