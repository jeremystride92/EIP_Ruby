class CardsController < ApplicationController
  before_filter :find_card

  def update
    authorize! :update, @card

    if @card.update_attributes params_for_card
      respond_to :json
    else
      head :unprocessable_entity
    end
  end

  private

  def params_for_card
    params.require(:card).permit(:card_level_id)
  end

  def find_card
    @card = Card.find(params[:id])
  end
end
