class Api::V1::SessionsController < ApplicationController
  def create
    cardholder = Cardholder.find_by_phone_number(params[:phone_number])
    if cardholder && cardholder.authenticate(params[:password])
      render json: { auth_token: cardholder.auth_token }
    else
      head :unauthorized
    end
  end
end
