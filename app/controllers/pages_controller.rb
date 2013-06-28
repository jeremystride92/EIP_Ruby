class PagesController < ApplicationController
  skip_authorization_check

  def index
    redirect_to venue_path if current_user
  end
end
