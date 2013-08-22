class SmsMailer < ActionMailer::Base
  default from: ENV['site_email']

  def cardholder_onboarding_sms(cardholder_id, venue_id)
    @cardholder = Cardholder.find(cardholder_id);
    raise "Cardholder not found: #{cardholder_id}" unless @cardholder.present?
    @venue = Venue.find(venue_id)
    raise "Venue not found: #{venue_id}" unless @venue.present?

    mail to: ENV['site_email'] # Needed to activate message (see https://github.com/rails/rails/pull/8048)
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: venue.sender_number, message: render_to_string)
  end

  def cardholder_new_card_sms(cardholder_id, venue_id)
    @cardholder = Cardholder.find(cardholder_id)
    @venue = Venue.find(venue_id)
    raise "Cardholder not found: #{cardholder_id}" unless @cardholder.present?
    raise "Venue not found: #{venue_id}" if @venue.nil?

    mail to: ENV['site_email'] # Needed to activate message
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: venue.sender_number, message: render_to_string)
  end

  def cardholder_promotion_message(cardholder_id, venue_id, message)

    cardholder = Cardholder.find(cardholder_id)
    @venue = Venue.find(venue_id)
    raise "Cardholder not found: #{cardholder_id}" unless cardholder.present?
    raise "Venue not found: #{venue_id}" if @venue.nil?

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: @venue.sender_number, message: message)
  end

  def temp_card_sms(card_id, venue_id, partner_id)
    @card = Card.find(card_id)
    @venue = Venue.find(venue_id)
    @partner = Partner.find(partner_id)

    raise "Cardholder not found: #{cardholder_id}" unless @cardholder.present?
    raise "Venue not found: #{venue_id}" unless @venue.present?
    raise "Partner not found: #{partner_id}" unless @partner.present?

    @link = $short_url_cache.shorten public_temporary_card_url(@card.access_token, subdomain: @venue.vanity_slug), skip_cache: true

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: card.international_phone_number, from: venue.sender_number, message: render_to_string)
  end

  def pin_reset_sms(cardholder_id)
    cardholder = Cardholder.find(cardholder_id)
    raise "Cardholder not found: #{cardholder_id}" unless cardholder.present?

    @token = cardholder.reset_token
    @phone_number = cardholder.phone_number

    raise "Venue not found for cardholder: #{cardholder_id}" unless cardholder.venues.count
    @venue = cardholder.venues.first

    @link = $short_url_cache.shorten reset_pin_cardholder_url(@token)

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: @venue.sender_number, message: render_to_string)
  end

end
