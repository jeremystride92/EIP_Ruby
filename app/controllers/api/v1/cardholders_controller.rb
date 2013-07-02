class Api::V1::CardholdersController < ApplicationController
  before_filter :authorize

  EAGER_LOAD_ASSOCIATIONS = { cards: [:benefits, :venue, :guest_passes, { card_level: [:benefits, :venue] }] }.freeze

  def show
    authorize! :read, @cardholder

    @cardholder.cards.each do |card|
      card.benefits.reject! &:inactive?
      card.card_level.benefits.reject! &:inactive?
      card.venue.promotions.reject! &:past?
    end
  end

  def checkin
    card = Card.find params[:card_id]
    authorize! :checkin, card

    guest_count = params[:guest_count].to_i

    if guest_count > card.total_guest_count
      render json: {error: "This cardholder has fewer passes than guests.", count: card.reload.total_guest_count }, status: :bad_request
    else
      card.checkin_guests! guest_count
      render json: { success: "Passes accepted", count: card.reload.total_guest_count }
    end
  end

  private

  def authorize
    if cardholder = authenticate_with_http_token { |token, options| Cardholder.includes(EAGER_LOAD_ASSOCIATIONS).find_by_auth_token(token) }
      @cardholder = cardholder
    else
      request_http_token_authentication
    end
  end

  def current_user
    @cardholder
  end
end
