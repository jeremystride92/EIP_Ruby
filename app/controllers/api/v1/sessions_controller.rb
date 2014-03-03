class Api::V1::SessionsController < ApplicationController
  skip_authorization_check

  def create
    cardholder = Cardholder.find_by_phone_number(params[:phone_number])
    if cardholder.nil?
      head :unauthorized
    elsif cardholder.pending?
      render json: { auth_token: nil, onboarding: onboard_url(cardholder.onboarding_token), onboarding_token: cardholder.onboarding_token }
    elsif pin_required?
      if cardholder.authenticate(params[:password])
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
