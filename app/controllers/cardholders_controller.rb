class CardholdersController < ApplicationController
  layout 'venue'

  before_filter :find_venue, except: :index
  before_filter :find_venue_with_cardholders, only: :index

  def index
    @cards_by_level = @venue.card_levels.reduce({}) do |memo, level|
      memo[level] = level.cards
      memo
    end
    @cards = @venue.card_levels.map(&:cards).flatten
  end

  def new
    @cardholder = Cardholder.new
  end

  def create
    if @cardholder = Cardholder.find_by_phone_number(params[:cardholder][:phone_number])
      @cardholder.cards.build params_for_cardholder[:cards_attributes]['0']
    else
      @cardholder = Cardholder.new params_for_cardholder # accepts nested attributes for the new card
    end


    if @cardholder.save
      redirect_to venue_cardholders_path, notice: 'Card issued'
    else
      render :new
    end
  end

  private

  def find_venue
    @venue = Venue.includes(:card_levels).find(current_user.venue_id)
  end

  def find_venue_with_cardholders
    @venue = Venue.includes(card_levels: { cards: :cardholder }).find(current_user.venue_id)
  end

  def params_for_cardholder
    params.require(:cardholder).permit(:first_name, :last_name, :phone_number, cards_attributes: [:card_level_id, :issuer_id])
  end
end
