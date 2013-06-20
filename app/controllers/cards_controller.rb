class CardsController < ApplicationController
  before_filter :find_card

  def edit
    @card.benefits.build unless @card.benefits.present?
  end

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
    authorize! :update, @card

    if @card.update_attributes(status: 'inactive')
      head :no_content
    else
      head :internal_server_error
    end
  end

  def activate_card
    authorize! :update, @card

    if @card.update_attributes(status: 'active')
      head :no_content
    else
      head :internal_server_error
    end
  end

  def change_card_level
    authorize! :update, @card

    if @card.update_attributes params_for_card
      respond_to do |format|
        format.json
        format.html { redirect_to venue_cardholders_path }
      end
    else
      respond_to do |format|
        format.json { head :unprocessable_entity }
        format.html { render 'edit' }
      end
    end
  end
  
  def params_for_card
    params.require(:card).permit(:card_level_id, benefits_attributes: [:description, :start_date, :end_date, :start_date_field, :end_date_field, :start_time_field, :end_time_field, :_destroy, :id])
  end

  def find_card
    @card = Card.find(params[:id])
  end
end
