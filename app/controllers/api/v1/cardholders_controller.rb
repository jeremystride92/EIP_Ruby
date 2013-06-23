class Api::V1::CardholdersController < ApplicationController
  before_filter :authorize

  def show
  end

  private

  def authorize

    if cardholder = authenticate_with_http_token { |token, options| Cardholder.find_by_auth_token(token) }
      @cardholder = cardholder

      @cardholder.cards.each do |card|
        card.benefits.reject! &:inactive?
        card.card_level.benefits.reject! &:inactive?
      end
    else
      request_http_token_authentication
    end
  end
end
