class VenuesController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue, only: [:show]

  def new
    @venue = Venue.new
  end

  def create
    @venue = Venue.new venue_params.merge(owner: current_user)

    if @venue.save
      redirect_to @venue, notice: 'Venue created!'
    else
      render :new
    end
  end

  def show
    authorize! :read, @venue
  end

  private
  def venue_params
    params.require(:venue).permit(:name, :phone, :location, :address1, :address2, :website, :vanity_slug, :logo, :logo_cache)
  end

  def find_venue
    @venue = current_user.venue
  end
end
