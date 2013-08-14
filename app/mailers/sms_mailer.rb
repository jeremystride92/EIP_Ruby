class SmsMailer < ActionMailer::Base
  default from: ENV['site_email']

  def cardholder_onboarding_sms(cardholder, venue)
    @cardholder = cardholder
    @venue = venue

    mail to: ENV['site_email'] # Needed to activate message (see https://github.com/rails/rails/pull/8048)
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: venue.sender_number, message: render_to_string)
  end

  def cardholder_new_card_sms(cardholder, venue)
    @cardholder = cardholder
    @venue = venue

    mail to: ENV['site_email'] # Needed to activate message
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: venue.sender_number, message: render_to_string)
  end

  def cardholder_promotion_message(cardholder, venue, message)
    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: venue.sender_number, message: message)
  end

  def temp_card_sms(card, venue, partner)
    @card = card
    @venue = venue
    @partner = partner
    @link = $short_url_cache.shorten public_temporary_card_url(@card.access_token, subdomain: @venue.vanity_slug), skip_cache: true

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: card.international_phone_number, from: venue.sender_number, message: render_to_string)
  end

  def pin_reset_sms(cardholder)
    @token = cardholder.reset_token
    @phone_number = cardholder.phone_number
    @venue = cardholder.venues.first

    @link = $short_url_cache.shorten reset_pin_cardholder_url(@token)

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: @venue.sender_number, message: render_to_string)
  end
end
