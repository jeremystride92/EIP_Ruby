class Api::V1::CardholdersController < ApplicationController
  def show
    phone_number = params[:id]
    @cardholder = Cardholder.where(phone_number: phone_number).first
  end
end
