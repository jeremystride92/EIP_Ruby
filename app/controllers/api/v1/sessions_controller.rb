class Api::V1::SessionsController < ApplicationController
  skip_authorization_check

  def create
    cardholder = Cardholder.find_by_phone_number(params[:phone_number])
    if cardholder.nil?
      head :unauthorized
    elsif cardholder.pending?
      render json: { auth_token: nil, onboarding: onboard_url(cardholder.onboarding_token) }
    else
      render json: { auth_token: cardholder.auth_token }
    end
  end
end
