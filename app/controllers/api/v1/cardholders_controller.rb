class Api::V1::CardholdersController < ApplicationController
  before_filter :authorize

  def show
    @cardholder.cards.each do |card|
      card.benefits.reject! &:inactive?
      card.card_level.benefits.reject! &:inactive?
    end
  end

  def checkin
    card = Card.find params[:card_id]
    guest_count = params[:guest_count].to_i

    if guest_count > card.guest_count
      render json: {error: "This cardholder has fewer passes than guests.", count: card.guest_count }, status: :bad_request
    else
      card.update_attributes guest_count: (card.guest_count - guest_count)
      render json: { success: "Passes accepted", count: card.guest_count }
    end
  end

  private

  def authorize

    if cardholder = authenticate_with_http_token { |token, options| Cardholder.find_by_auth_token(token) }
      @cardholder = cardholder
    else
      request_http_token_authentication
    end
  end
end
