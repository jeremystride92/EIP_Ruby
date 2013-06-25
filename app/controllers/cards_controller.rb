class CardsController < ApplicationController
  before_filter :find_card, except: [:request_card_form, :request_card]
  before_filter :find_venue_by_slug, only: [:request_card_form, :request_card]

  def edit_benefits
    @card.benefits.build unless @card.benefits.present?
  end

  def edit_guest_passes
    @card.guest_passes.build unless @card.guest_passes.present?
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
    when 'Edit Benefits'
      edit_benefits
    when 'Issue Guest Passes'
      issue_guest_passes
    else
      head :unproccessable_entity
    end
  end

  def request_card_form
    @cardholder = Cardholder.new
  end

  def request_card
    @card = @venue.default_signup_card_level.cards.build(status: 'pending')
    if @cardholder = Cardholder.find_by_phone_number(params[:cardholder][:phone_number])
      if @cardholder.authenticate params[:cardholder][:password]
        @cardholder.cards << @card
        @cardholder.save
      else
        @cardholder = Cardholder.new(params_for_card_request)
        @cardholder.errors.add :password, 'Incorrect Password'
        render 'request_card_form'
      end
    else
      if @cardholder = Cardholder.create(params_for_card_request)
        @cardholder.cards << @card
      else
        render 'request_card_form'
      end
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
      respond_to :json
    else
      head :unprocessable_entity
    end
  end

  def edit_benefits
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

  def issue_guest_passes
    new_pass_count = params[:guest_count].to_i

    new_pass_count.times do
      @card.guest_passes.build(params_for_guest_pass)
    end

    if @card.save
      redirect_to venue_cardholders_path, notice: "#{new_pass_count} passes issued."
    else
      flash.now[:error] = 'An unknown error occurred. Please try again later.'
      render :edit_guest_passes
    end
  end

  def params_for_card
    params.require(:card).permit(:card_level_id, benefits_attributes: [:description, :start_date, :end_date, :start_date_field, :end_date_field, :start_time_field, :end_time_field, :_destroy, :id])
  end

  def params_for_guest_pass
    params.permit :start_date, :end_date
  end

  def params_for_card_request
    params.require(:cardholder).permit(:phone_number, :password, :first_name, :last_name)
  end

  def find_card
    id = params[:id] || params[:card_id]
    @card = Card.find(id)
  end

  def find_venue_by_slug
    @venue = Venue.find_by_vanity_slug!(params[:venue_slug])
  end
end
