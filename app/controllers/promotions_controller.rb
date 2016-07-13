class PromotionsController < ApplicationController
  before_filter :find_venue, except: :public_show
  before_filter :find_venue_by_vanity_slug, only: :public_show
  before_filter :find_promotion, except: [:new, :create, :index]
  before_filter :find_all_promotions, only: :index

  PUBLIC_ACTIONS = [:public_show]
  public_actions *PUBLIC_ACTIONS

  before_filter :authenticate, except: PUBLIC_ACTIONS
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
    @promotion.increment!(:view_count)
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
      redirect_to venue_promotions_path
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :destroy, @promotion
    @promotion.expire!

    respond_to do |format|
      format.json { head :no_content }
      format.js { head :no_content }
      format.html { redirect_to venue_path }
    end
  end

  def promote
    authorize! :promote, @promotion
    @promo_message = PromotionalMessage.new message: $short_url_cache.shorten(public_promotion_url subdomain: @venue.vanity_slug, id: @promotion.id), card_levels: []
  end

  def send_promotion
    authorize! :promote, @promotion

    Time.use_zone @venue.time_zone do
      @promo_message = PromotionalMessage.new params_for_promotion_message
      @promo_message.promotion = @promotion
      @promo_message.card_levels = CardLevel.where(id: params_for_card_levels)
    end
    @card_levels = CardLevel.includes(cards: [:cardholder]).find(@promo_message.card_level_ids) & @venue.card_levels
    @cards = @card_levels.flat_map(&:cards).select(&:active?)
    @cardholders = @cards.map(&:cardholder).uniq.select(&:present?).select(&:active?)

    if @cardholders.empty?
      flash[:error] = "No Cards were found in those Card Levels."
      render :promote and return
    end

    @card_levels.each do |card_level|
      card_level.promotions << @promotion unless card_level.promotions.include? @promotion
    end

    @promo_message.save

    case params[:commit]
    when 'Send Now'
      @cardholders.each do |cardholder|
        # PK Edits
        # SmsMailer.delay(retry: false).cardholder_promotion_message(cardholder.id, @venue.id, @promo_message.message)
        SmsMailer.cardholder_promotion_message(cardholder.id, @venue.id, @promo_message.message)
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

  def index
    authorize! :read, Promotion
  end

  private

  def params_for_promotion
    params.require(:promotion).permit(:title, :description, :start_date_field, :start_time_field, :end_date_field, :end_time_field, :image, :image_cache)
  end

  def params_for_promotion_message
    params.require(:promotional_message).permit(:message, :send_date_time)
  end

  def params_for_card_levels
    params.require(:promotional_message).require(:card_levels)
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

  def find_all_promotions
    @promotions = @venue.promotions.sort.reverse
  end
end
