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
    @promo_message = PromotionMessage.new
  end

  def send_promotion
    authorize! :promote, @promotion

    @promo_message = PromotionMessage.new *(params_for_promotion_message.values_at 'message', 'card_levels')
    @promo_message.card_levels.reject! &:empty?

    @card_levels = CardLevel.includes(cards: [:cardholder]).find(@promo_message.card_levels) & @venue.card_levels
    @cardholders = @card_levels.map(&:cards).flatten.map(&:cardholder).uniq

    if @cardholders.empty?
      render :promote, notice: "No Cards were found in those Card Levels." and return
    end

    @cardholders.each do |cardholder|
      SmsMailer.delay.cardholder_promotion_message(cardholder, @venue, @promo_message.message)
    end
  end

  private

  def params_for_promotion
    params.require(:promotion).permit(:title, :description, :start_date_field, :start_time_field, :end_date_field, :end_time_field, :image, :image_cache)
  end

  def params_for_promotion_message
    params.require(:promotion_message).permit(:message, card_levels: [])
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
