class VenuesController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue, only: [:show]

  layout 'venue', except: [:new, :create]

  def new
    @venue = Venue.new
  end

  def create
    @venue = Venue.new venue_params

    if @venue.save
      redirect_to new_venue_card_level_path, notice: 'Venue created! Now set up some card levels.'
      current_user.update_attributes venue_id: @venue.id
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
    redirect_to :new_venue and return if current_user.venue_id.nil?

    @venue = Venue.includes(:card_levels).find(current_user.venue_id)
  end
end
