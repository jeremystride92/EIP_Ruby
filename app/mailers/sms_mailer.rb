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
end
