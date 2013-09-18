class Api::V1::CardholdersController < ApplicationController
  before_filter :authorize

  EAGER_LOAD_ASSOCIATIONS = { cards: [:benefits, :redeemable_benefits, { card_level: [:benefits, :venue, :promotions ] }] }.freeze

  def show
    authorize! :read, @cardholder

    @cardholder.cards.each do |card|
      card.benefits.reject! &:inactive?
      card.card_level.benefits.reject! &:inactive?
      card.card_level.promotions.reject! &:past?
    end
  end

  def redeem
    card = Card.find params[:card_id]
    authorize! :redeem, card

    benefit_redemption_count = params[:benefit_redemption_count].to_i

    if benefit_redemption_count > card.total_redeemable_benefit_allotment
      render json: {error: "This cardholder does not have enough benefits.", count: card.reload.total_redeemable_benefit_allotment }, status: :bad_request
    else
      card.redeem_benefits! benefit_redemption_count
      render json: { success: "Benefits accepted", count: card.reload.total_redeemable_benefit_allotment }
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
