class PromotionsController < ApplicationController
  before_filter :find_venue, except: :public_show
  before_filter :find_promotion, except: [:new, :create]

  PUBLIC_ACTIONS = [:public_show]
  public_actions *PUBLIC_ACTIONS
  skip_authorization_check only: PUBLIC_ACTIONS

  def new
    @promotion = @venue.promotions.build
    authorize! :create, @promotion
  end

  def create
    @promotion = @venue.promotions.build(params_for_promotion)
    authorize! :create, @promotion

    if @promotion.save
      redirect_to venue_promotion_path(@promotion)
    else
      render 'new'
    end
  end

  def show
    authorize! :read, @promotion
  end

  def public_show
    @venue = Venue.find_by_vanity_slug params[:venue_slug]
    @promotion = Promotion.find params[:id]
  end

  def edit
    authorize! :update, @promotion
  end

  def update
    authorize! :update, @promotion

    if @promotion.update_attributes(params_for_promotion)
      redirect_to venue_promotion_path(@promotion)
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

    card_levels = CardLevel.includes(cards: [:cardholder]).find(@promo_message.card_levels) & @venue.card_levels
    cardholders = card_levels.map(&:cards).flatten.map(&:cardholder).uniq

    binding.pry
    cardholders.each do |cardholder|
      SmsMailer.cardholder_promotion_message(cardholder, @venue, @promo_message.message).deliver
    end

    render :promote
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

  def find_promotion
    @promotion = Promotion.find (params[:id] || params[:promotion_id])
  end
end
