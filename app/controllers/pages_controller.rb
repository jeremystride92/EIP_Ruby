class PagesController < ApplicationController
  def index
    redirect_to venue_path if current_user
  end
end
