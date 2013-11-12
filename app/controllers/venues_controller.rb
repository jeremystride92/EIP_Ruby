class VenuesController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue, except: [:new, :create]
  before_filter :find_promotions, only: [:show]

  public_actions :new, :create

  def new
    if current_user && current_user.venue_id
      flash[:error] = 'There is already a business associated to this account. To create a new business, please use another account.'
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
      redirect_to new_venue_card_theme_path, notice: 'Business created! Now upload your card themes!'
      current_user.update_attributes venue_id: @venue.id
      AdminMailer.delay(retry: false).new_venue_email(@venue)
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
      redirect_to venue_path, notice: "Business information updated"
    else
      render :edit
    end
  end

  def edit_kiosk
    authorize! :update, @venue
  end

  def update_kiosk
    authorize! :update, @venue

    if @venue.update_attributes(kiosk_params_for_update)
      redirect_to venue_path, notice: "Kiosk background updated. Refresh any devices that have the kiosk open to see the new image."
    else
      render :edit_kiosk
    end
  end

  private

  def venue_params
    params.require(:venue).permit(:name, :phone, :location, :address1, :address2, :website, :vanity_slug, :logo, :logo_cache, :time_zone)
  end

  def venue_params_for_update
    attributes = [:name, :phone, :location, :address1, :address2, :website, :vanity_slug, :logo, :logo_cache, :time_zone]
    attributes -= [:vanity_slug] if @venue.vanity_slug.present?

    params.require(:venue).permit *attributes
  end

  def kiosk_params_for_update
    params.require(:venue).permit(:kiosk_background, :kiosk_background_cache)
  end

  def find_venue
    redirect_to(:new_venue, notice: "You've signed up for EIPiD, But haven't entered your venue information yet. Fill out the form below to continue.") and return if current_user.venue_id.nil?

    @venue = Venue.includes(:promotions, card_levels: [:card_theme, :cards, :redeemable_benefits], partners: [:card_theme, :temporary_cards]).find(current_user.venue_id)
  end

  def find_promotions
    @promotions = @venue.promotions.sort.reverse
  end
end
