class Api::V1::CardholdersController < ApplicationController
  def show
    phone_number = params[:id]
    @cardholder = Cardholder.includes(cards: { card_level: :venue }).where(phone_number: phone_number).first
  end
end
