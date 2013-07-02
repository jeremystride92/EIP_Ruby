class VenuesController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue, except: [:new, :create]
  before_filter :find_promotions, only: [:show]

  public_actions :new, :create

  def new
    if current_user && current_user.venue_id
      flash[:error] = 'There is already a venue associated to this account. To create a new venue, please use another account.'
      authorize! :read, current_user.venue
      redirect_to venue_path and return
    end

    @venue = Venue.new
    authorize! :create, @venue
  end

  def create
    @venue = Venue.new venue_params
    authorize! :create, @venue

    if @venue.save
      redirect_to new_venue_card_level_path, notice: 'Venue created! Now set up some card levels.'
      current_user.update_attributes venue_id: @venue.id
    else
      render :new
    end
  end

  def show
    authorize! :read, @venue
    authorize! :read, Promotion
  end

  def edit
    authorize! :update, @venue
  end

  def update
    authorize! :update, @venue

    if @venue.update_attributes(venue_params_for_update)
      redirect_to venue_path, notice: "Venue information updated"
    else
      render :edit
    end
  end

  private

  def venue_params
    params.require(:venue).permit(:name, :phone, :location, :address1, :address2, :website, :vanity_slug, :logo, :logo_cache)
  end

  def venue_params_for_update
    attributes = [:name, :phone, :location, :address1, :address2, :website, :vanity_slug, :logo, :logo_cache]
    attributes -= [:vanity_slug] if @venue.vanity_slug.present?

    params.require(:venue).permit *attributes
  end


  def find_venue
    redirect_to(:new_venue, notice: "You've signed up for EIPiD, But haven't entered your venue information yet. Fill out the form below to continue.") and return if current_user.venue_id.nil?

    @venue = Venue.includes(:card_levels, :promotions).find(current_user.venue_id)
  end

  def find_promotions
    @promotions = @venue.promotions.order('start_date DESC')
  end
end
