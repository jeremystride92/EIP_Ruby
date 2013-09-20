class Kiosk::CardRequestsController < ApplicationController
  before_filter :find_venue_by_slug
  before_filter :logout_user

  public_actions :new, :create

  skip_authorization_check

  def new
    @cardholder = Cardholder.new
    render layout: 'kiosk'
  end

  def create
    card = @venue.default_signup_card_level.cards.build status: 'pending'

    @cardholder = Cardholder.find_by_phone_number params[:cardholder][:phone_number]

    message = "Thanks for signing up! You'll receive a confirmation text message shortly."
    if @cardholder && @cardholder.has_card_for_venue?(@venue)
      message = "You already have a card with #{@venue.name}!"
    elsif @cardholder
      @cardholder.cards << card
      @cardholder.save
      SmsMailer.delay(retry: false).card_request_confirmation_sms(@cardholder.id, @venue.id)
    else
      @cardholder = Cardholder.new params_for_cardholder
      @cardholder.cards << card

      if !@cardholder.save
        render 'new' and return
      else
        SmsMailer.delay(retry: false).card_request_confirmation_sms(@cardholder.id, @venue.id)
      end
    end

    redirect_to new_kiosk_card_requests_path, notice: message
  end

  private

  def find_venue_by_slug
    @venue = Venue.find_by_vanity_slug! request.subdomain
  end

  def params_for_cardholder
    params.require(:cardholder).permit(:phone_number)
  end

  def logout_user
    cookies.delete(:auth_token)
    @current_user = nil
  end

end
