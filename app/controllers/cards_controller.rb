class CardsController < ApplicationController
  before_filter :find_card

  def update
    authorize! :update, @card

    case params[:commit]
    when 'Deactivate'
      deactivate_card
    when 'Activate'
      activate_card
    when 'Change'
      change_card_level
    else
      head :unproccessable_entity
    end
  end

  private

  def deactivate_card
    if @card.update_attributes(status: 'inactive')
      head :no_content
    else
      head :internal_server_error
    end
  end

  def activate_card
    if @card.update_attributes(status: 'active')
      head :no_content
    else
      head :internal_server_error
    end
  end

  def change_card_level
    if @card.update_attributes params_for_card
      respond_to :json
    else
      head :unprocessable_entity
    end
  end

  def params_for_card
    params.require(:card).permit(:card_level_id)
  end

  def find_card
    @card = Card.find(params[:id])
  end
end
