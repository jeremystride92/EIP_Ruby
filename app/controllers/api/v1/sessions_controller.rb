class Api::V1::SessionsController < ApplicationController
  skip_authorization_check

  def create
    cardholder = Cardholder.find_by_phone_number(params[:phone_number])
    if cardholder.nil?
      head :unauthorized
    elsif cardholder.pending?
      render json: {
          auth_token: nil,
          onboarding: onboard_url(cardholder.onboarding_token),
          onboarding_token: cardholder.onboarding_token,
          first_name: cardholder.first_name,
          last_name: cardholder.last_name
      }
    elsif pin_required?
      if cardholder.authenticate(params[:password])
        render json: { auth_token: cardholder.auth_token }
      else 
        head :unauthorized
      end
    elsif params[:venue_id].present?
      if cardholder.cards.map(&:venue).map(&:id).include? params[:venue_id].to_i
        render json: { auth_token: cardholder.auth_token }
      else
        head :unauthorized
      end
    else
      render json: { auth_token: cardholder.auth_token }
    end
  end

  def requires_pin_authentication
    render json: { require_pin: pin_required? }
  end

end
