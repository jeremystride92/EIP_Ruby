class CardholdersController < ApplicationController
  include ActionView::Helpers::TextHelper

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

  def batch_new
    @card_level = CardLevel.find(params[:card_level_id])
  end

  def batch_create
    cardholders = params[:cardholders].map do |index, ch_attr|
      attrs = ch_attr.merge(cards_attributes: { '0' => { card_level_id: params[:card_level_id], issuer_id: current_user.id } })
      create_cardholder_or_card attrs
    end

    cardholders.each do |ch|
      authorize! :create, ch.cards.last
      ch.save
    end

    @problems = cardholders.select &:invalid?

    if @problems.empty?
      redirect_to venue_cardholders_path, notice: "#{pluralize(cardholders.count, 'card')} issued"
    else
      @card_level = CardLevel.find params[:card_level_id]
      render 'redo_batch'
    end
  end

  private

  def create_cardholder_or_card(attributes)
    if cardholder = Cardholder.find_by_phone_number(attributes[:phone_number])
      cardholder.cards.build attributes[:cards_attributes]['0']
    else
      cardholder = Cardholder.new attributes # accepts nested attributes for the new card
    end

    cardholder
  end

  def find_venue
    @venue = Venue.includes(:card_levels).find(current_user.venue_id)
  end

  def params_for_cardholder
    params.require(:cardholder).permit(:first_name, :last_name, :phone_number, cards_attributes: [:card_level_id, :issuer_id])
  end
end
