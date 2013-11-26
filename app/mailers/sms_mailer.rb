require 'nexmo_sender'

class SmsMailer < ActionMailer::Base
  default from: ENV['site_email']

  def cardholder_onboarding_sms(cardholder_id, venue_id)
    binding.pry
    @cardholder = Cardholder.find(cardholder_id)
    @venue = Venue.find(venue_id)

    mail to: ENV['site_email'] # Needed to activate message (see https://github.com/rails/rails/pull/8048)
    self.message.delivery_handler = NexmoSender.new(to: @cardholder.international_phone_number, from: @venue.sender_number, message: render_to_string)
  end

  def cardholder_new_card_sms(cardholder_id, venue_id)
    @cardholder = Cardholder.find(cardholder_id)
    @venue = Venue.find(venue_id)

    mail to: ENV['site_email'] # Needed to activate message
    self.message.delivery_handler = NexmoSender.new(to: @cardholder.international_phone_number, from: @venue.sender_number, message: render_to_string)
  end

  def cardholder_promotion_message(cardholder_id, venue_id, message)

    cardholder = Cardholder.find(cardholder_id)
    @venue = Venue.find(venue_id)

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: @venue.sender_number, message: message)
  end

  def temp_card_sms(temp_card_id, venue_id, partner_id)
    @card = TemporaryCard.find(temp_card_id)
    @venue = Venue.find(venue_id)
    @partner = Partner.find(partner_id)

    @link = $short_url_cache.shorten public_temporary_card_url(@card.access_token, subdomain: @venue.vanity_slug), skip_cache: true

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: @card.international_phone_number, from: @venue.sender_number, message: render_to_string)
  end

  def pin_reset_sms(cardholder_id)
    cardholder = Cardholder.find(cardholder_id)

    @token = cardholder.reset_token
    @venue = cardholder.venues.first
    @link = $short_url_cache.shorten reset_pin_cardholder_url(@token)

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: @venue.sender_number, message: render_to_string)
  end

  def cardholder_new_benefit_sms(cardholder_id, venue_id, count)
    cardholder = Cardholder.find cardholder_id
    @venue = Venue.find venue_id

    @count = count

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: @venue.sender_number, message: render_to_string)
  end

  def cardholder_new_redeemable_benefit_sms(cardholder_id, venue_id, count)
    cardholder = Cardholder.find cardholder_id
    @venue = Venue.find venue_id

    card = @venue.cards.where(cardholder_id: cardholder_id).first
    @benefit_title = card.card_level.redeemable_benefit_title

    @count = count

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: @venue.sender_number, message: render_to_string)
  end

  def card_request_confirmation_sms(cardholder_id, venue_id)
    cardholder = Cardholder.find cardholder_id
    venue = Venue.find venue_id
    @venue_name = venue.name

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: venue.sender_number, message: render_to_string)
  end

  def card_level_change_sms(cardholder_id, new_card_level_id, venue_id)
    cardholder = Cardholder.find cardholder_id
    new_card_level = CardLevel.find new_card_level_id
    venue = Venue.find venue_id

    @new_card_level_name = new_card_level.name
    @venue_name = venue.name

    mail to: ENV['site_email']
    self.message.delivery_handler = NexmoSender.new(to: cardholder.international_phone_number, from: venue.sender_number, message: render_to_string)
  end
end
