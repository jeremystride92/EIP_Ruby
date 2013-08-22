class PromotionsController < ApplicationController
  before_filter :find_venue, except: :public_show
  before_filter :find_venue_by_vanity_slug, only: :public_show
  before_filter :find_promotion, except: [:new, :create]

  PUBLIC_ACTIONS = [:public_show]
  public_actions *PUBLIC_ACTIONS
  skip_authorization_check only: PUBLIC_ACTIONS

  def new
    @promotion = @venue.promotions.build
    authorize! :create, @promotion
  end

  def create
    @promotion = @venue.promotions.build params_for_promotion

    authorize! :create, @promotion

    success = false
    Time.use_zone @venue.time_zone do
      success = @promotion.save
    end

    if success
      redirect_to venue_promotion_path @promotion
    else
      render 'new'
    end
  end

  def show
    authorize! :read, @promotion
  end

  def public_show
  end

  def edit
    authorize! :update, @promotion
  end

  def update
    authorize! :update, @promotion

    success = false
    Time.use_zone @venue.time_zone do
      success = @promotion.update_attributes params_for_promotion
    end

    if success
      redirect_to venue_promotion_path @promotion
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :destroy, @promotion
    @promotion.destroy
    head :no_content
  end

  def promote
    authorize! :promote, @promotion
    @promo_message = PromotionMessage.new message: $short_url_cache.shorten(public_promotion_url subdomain: @venue.vanity_slug, id: @promotion.id), card_levels: []
  end

  def send_promotion
    authorize! :promote, @promotion

    Time.use_zone @venue.time_zone do
      @promo_message = PromotionMessage.new params_for_promotion_message
    end

    @card_levels = CardLevel.includes(cards: [:cardholder]).find(@promo_message.card_levels) & @venue.card_levels
    @cardholders = @card_levels.map(&:cards).flatten.map(&:cardholder).uniq

    if @cardholders.empty?
      flash[:error] = "No Cards were found in those Card Levels."
      render :promote and return
    end

    @card_levels.each do |card_level|
      card_level.promotions << @promotion unless card_level.promotions.include? @promotion
    end

    case params[:commit]
    when 'Send Now'
      @cardholders.each do |cardholder|
        SmsMailer.delay(retry: false).cardholder_promotion_message(cardholder.id, @venue.id, @promo_message.message)
      end
    when 'Schedule'
      if @promo_message.send_date_time < Time.current
        flash[:error] = "You cannot schedule a promotion for the past."
        render :promote and return
      end

      @cardholders.each do |cardholder|
        SmsMailer.delay_until(@promo_message.send_date_time, retry: false).cardholder_promotion_message(cardholder.id, @venue.id, @promo_message.message)
      end
    end
  end

  private

  def params_for_promotion
    params.require(:promotion).permit(:title, :description, :start_date_field, :start_time_field, :end_date_field, :end_time_field, :image, :image_cache)
  end

  def params_for_promotion_message
    params.require(:promotion_message).permit(:message, :send_date_time, card_levels: [])
  end

  def find_venue
    @venue = current_user.venue
  end

  def find_venue_by_vanity_slug
    @venue = Venue.find_by_vanity_slug! request.subdomain
  end

  def find_promotion
    @promotion = @venue.promotions.find (params[:id] || params[:promotion_id])
  end
end
