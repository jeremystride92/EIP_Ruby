class Api::V1::CardholdersController < ApplicationController
  EAGER_LOAD_ASSOCIATIONS = {cards: [:benefits, :redeemable_benefits, {card_level: [:benefits, :venue, :promotions]}]}.freeze

  before_filter :authorize, :only => [:show, :redeem]

  skip_authorization_check only: :complete_onboard

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
      render json: {error: "This cardholder does not have enough benefits.", count: card.reload.total_redeemable_benefit_allotment}, status: :bad_request
    else
      card.redeem_benefits! benefit_redemption_count
      render json: {success: "Benefits accepted", count: card.reload.total_redeemable_benefit_allotment}
    end
  end

  def complete_onboard
    cardholder = Cardholder.find_by_onboarding_token cardholder_onboarding_params[:onboarding_token]
    if cardholder.activate! cardholder_onboarding_params
      render json: {success: "Cardholder updated"}, status: :ok
    else
      render json: {error: cardholder.errors.full_messages.join(", ")}, status: :bad_request
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

  def cardholder_onboarding_params
    params.require(:cardholder).permit(:onboarding_token, :first_name, :last_name, :photo, :photo_cache)
  end
end
