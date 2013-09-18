class CardLevelsController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue
  before_filter :find_venue_card_levels, only: [:index]
  before_filter :find_card_level, only: [:edit, :update, :reorder]

  def index
    authorize! :read, CardLevel if @card_levels.empty?

    @card_levels.each do |card_level|
      authorize! :read, card_level
    end
  end


  def new
    @card_level = @venue.card_levels.build
    authorize! :create, @card_level

    @card_level.benefits.build
  end

  def create
    @card_level = @venue.card_levels.build card_level_params
    authorize! :create, @card_level

    if @card_level.save
      redirect_to venue_card_levels_path, notice: 'Card level created.'
    else
      render :new
    end
  end

  def edit
    authorize! :update, @card_level
  end

  def update
    authorize! :update, @card_level

    if @card_level.update_attributes(card_level_params)
      redirect_to venue_card_levels_path, notice: 'Card level updated.'
    else
      render :edit
    end
  end

  def reorder
    authorize! :update, @card_level

    @card_level.reorder_to params[:sort_position].to_i

    redirect_to venue_card_levels_path
  end

  private

  def find_venue
    @venue = Venue.includes(card_levels: [:card_theme]).find(current_user.venue_id)
  end

  def find_venue_card_levels
    @card_levels = @venue.card_levels
  end

  def find_card_level
    @card_level = CardLevel.includes(:card_theme).where(venue_id: @venue).find(params[:id] || params[:card_level_id])
  end

  def card_level_params
    params.require(:card_level).permit(:name, :card_theme_id, :redeemable_benefit_name, :daily_redeemable_benefit_allotment, permanent_benefits_attributes: [:id, :description, :_destroy], temporary_benefits_attributes: [:id, :description, :start_date_field, :start_time_field, :end_date_field, :end_time_field, :_destroy])
  end
end
