class Api::V1::CardholdersController < ApplicationController
  before_filter :authorize
  def show
  end

  private
    def authorize
      if cardholder = authenticate_with_http_token { |token, options| Cardholder.find_by_auth_token(token) }
        @cardholder = cardholder
      else
        if Rails.env.development? && params[:phone].present?
          @cardholder = Cardholder.find_by_phone_number(params[:phone])
        else
          request_http_token_authentication
        end
      end
    end
end
