class VenuesController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue, except: [:new, :create]

  layout 'venue', except: [:new, :create]

  def new
    if current_user && current_user.venue_id
      flash[:error] = 'There is already a venue associated to this account. To create a new venue, please use another account.'
      redirect_to venue_path
    end

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

  def edit
    authorize! :update, @venue
  end

  def update
    authorize! :update, @venue

    if @venue.update_attributes(venue_params)
      redirect_to venue_path, notice: "Venue information updated"
    else
      render :edit
    end
  end

  private
  def venue_params
    if @venue && @venue.persisted? && @venue.vanity_slug.present?
      params.require(:venue).permit(:name, :phone, :location, :address1, :address2, :website, :logo, :logo_cache)
    else
      params.require(:venue).permit(:name, :phone, :location, :address1, :address2, :website, :vanity_slug, :logo, :logo_cache)
    end
  end

  def find_venue
    redirect_to(:new_venue, notice: "You've signed up for EIPiD, But haven't entered your venue information yet. Fill out the form below to continue.") and return if current_user.venue_id.nil?

    @venue = Venue.includes(:card_levels).find(current_user.venue_id)
  end
end
