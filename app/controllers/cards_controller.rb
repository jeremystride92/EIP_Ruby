class CardsController < ApplicationController
  before_filter :authenticate, except: [:request_card_form, :request_card]

  before_filter :find_card, except: [:request_card_form, :request_card]

  before_filter :find_venue_by_slug, only: [:request_card_form, :request_card]
  before_filter :find_venue, except: [:request_card_form, :request_card]

  skip_authorization_check only: [:request_card_form, :request_card]

  public_actions :request_card_form, :request_card

  def edit_benefits
    Time.use_zone @venue.time_zone do
      @card.benefits.build unless @card.benefits.present?
    end

    @card.benefits.each do |benefit|
      authorize! :manage, benefit
    end
  end

  def edit_redeemable_benefits
    Time.use_zone @venue.time_zone do
      @card.redeemable_benefits.build unless @card.redeemable_benefits.present?
    end

    authorize! :create, @card.redeemable_benefits.last
  end

  def review_card_request
    authorize! :update, @card

    if params[:approve]
      approve_card
    elsif params[:reject]
      reject_card
    else
      head :unprocessable_entity
    end
  end

  def request_card_form
    @cardholder = Cardholder.new
  end

  def request_card
    @card = @venue.default_signup_card_level.cards.build(status: 'pending')
    if @cardholder = Cardholder.find_by_phone_number(params[:cardholder][:phone_number])
      if @cardholder.authenticate params[:cardholder][:password]
        if @cardholder.has_card_for_venue?(@venue)
          render 'card_exists'
        else
          @cardholder.cards << @card
          @cardholder.save
        end
      else
        @cardholder = Cardholder.new(params_for_card_request) # recreate cardholder so that no information leaks to the form
        @cardholder.errors.add :password, 'Incorrect Password'
        @incorrect_password = true
        render 'request_card_form'
      end
    else

      @cardholder= Cardholder.new(params_for_card_request)
      if @cardholder.save
        @cardholder.cards << @card
        @cardholder.save
      else
        @validation_errors=true
        render 'request_card_form'
      end
    end

  end

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

    card_level = CardLevel.find(params_for_card[:card_level_id])

    if @card.update_attributes params_for_card
      @card.redeemable_benefit_allotment= card_level.allowed_redeemable_benefits_count
      SmsMailer.delay(retry: false).card_level_change_sms(@card.cardholder_id, @card.card_level_id, @venue.id)
      respond_to :json
    else
      head :unprocessable_entity
    end
  end

  def update_benefits
    authorize! :update, @card
    authorize! :manage, Benefit

    old_benefit_ids = @card.benefits.map &:id

    success = false
    Time.use_zone @venue.time_zone do
      success = @card.update_attributes params_for_card
    end



    if success
      new_benefit_ids = @card.benefits.map &:id
      new_benefits_count = (new_benefit_ids - old_benefit_ids).count

      if new_benefits_count > 0
        SmsMailer.delay(retry: false).cardholder_new_benefit_sms(@card.cardholder_id, @venue.id, new_benefits_count)
      end

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

  def issue_redeemable_benefits
    authorize! :update, @card
    authorize! :create, RedeemableBenefit
    new_redeemable_benefit_count = params[:redeemable_benefit_allotment].to_i


    success = false
    Time.use_zone @venue.time_zone do
      new_redeemable_benefit_count.times do
        @card.redeemable_benefits.build(params_for_redeemable_benefit)
      end

      success = @card.save
    end

    if success
      SmsMailer.delay(retry: false).cardholder_new_redeemable_benefit_sms(@card.cardholder_id, @venue.id, new_redeemable_benefit_count)
      redirect_to venue_cardholders_path, notice: "#{new_redeemable_benefit_count} redeemable benefits issued."
    else
      flash.now[:error] = 'An unknown error occurred. Please try again later.'
      render :edit_redeemable_benefits
    end
  end

  def destroy
    authorize! :destroy, @card

    @card.destroy

    head :no_content
  end

  private

  def approve_card
    if params[:card][:card_level_id].empty?
      head :unprocessable_entity
      return
    end

    card_level = CardLevel.find(params[:card][:card_level_id])

    if @card.update_attributes(status: 'active', card_level: card_level, redeemable_benefit_allotment: card_level.allowed_redeemable_benefits_count, issuer: current_user, issued_at: Time.zone.now)
      SmsMailer.delay(retry: false).cardholder_new_card_sms(@card.cardholder.id, @venue.id)

      head :no_content
    else
      head :unprocessable_entity
    end
  end

  def reject_card
    authorize! :delete, @card
    if @card.pending?
      @card.destroy
      head :no_content
    else
      head :unprocessable_entity
    end
  end

  def params_for_card
    params.require(:card).permit(:card_level_id, benefits_attributes: [:description, :start_date_field, :end_date_field, :start_time_field, :end_time_field, :_destroy, :id])
  end

  def params_for_redeemable_benefit
    params.permit :start_date, :end_date
  end

  def params_for_card_request
    params.require(:cardholder).permit(:phone_number, :password, :password_confirmation, :first_name, :last_name, :sourceable_type, :sourceable_id)
  end

  def find_card
    id = params[:id] || params[:card_id]
    @card = Card.includes(:benefits, :redeemable_benefits).find(id)
  end

  def find_venue
    @venue = current_user.venue
  end

  def find_venue_by_slug
    @venue = Venue.find_by_vanity_slug! request.subdomain
  end
end
