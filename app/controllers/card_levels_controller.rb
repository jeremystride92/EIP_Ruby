class CardLevelsController < ApplicationController
  before_filter :find_venue
  before_filter :find_venue_card_levels, only: [:index]
  before_filter :find_card_level, only: [:edit, :update]

  def index
  end


  def new
    @card_level = @venue.card_levels.build
  end

  def create
    @card_level = @venue.card_levels.build card_level_params
    @card_level.benefits = @card_level.benefits.split("\n").map(&:strip)

    if @card_level.save
      redirect_to venue_card_levels_path, notice: 'Card level created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    card_level_attributes = card_level_params
    card_level_attributes[:benefits] = card_level_attributes[:benefits].split("\n").map(&:strip)
    if @card_level.update_attributes(card_level_attributes)
      redirect_to venue_card_levels_path, notice: 'Card level updated.'
    else
      render :edit
    end
  end

  private

  def find_venue
    @venue = Venue.includes(:card_levels).find(current_user.venue_id)
  end

  def find_venue_card_levels
    @card_levels = @venue.card_levels
  end

  def find_card_level
    @card_level = CardLevel.where(venue_id: @venue).find(params[:id])
  end

  def card_level_params
    params.require(:card_level).permit(:name, :benefits, :theme)
  end
end
