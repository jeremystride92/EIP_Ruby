class CardholdersController < ApplicationController
  layout 'venue'

  before_filter :find_venue

  def index
    @card_levels = @venue.card_levels

    @cards = Card.for_venue(@venue.id).joins(:cardholder).order('cardholders.last_name ASC')

    if params[:card_level_id].present?
      @cards = @cards.where(card_level_id: params[:card_level_id])
      @card_level_id = params[:card_level_id]
    end

    if params[:filter].present?
      search_string = "%#{params[:filter]}%"
      @cards = @cards.where('cardholders.last_name LIKE ?', search_string)
      @filter_string = params[:filter]
    end
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
      case params[:commit]
      when /continue/i
        redirect_to new_venue_cardholder_path, notice: "Card issued for #{@cardholder.phone_number}"
      else
        redirect_to venue_cardholders_path, notice: 'Card issued'
      end
    else
      render :new
    end
  end

  private

  def find_venue
    @venue = Venue.includes(:card_levels).find(current_user.venue_id)
  end

  def params_for_cardholder
    params.require(:cardholder).permit(:first_name, :last_name, :phone_number, cards_attributes: [:card_level_id, :issuer_id])
  end
end
