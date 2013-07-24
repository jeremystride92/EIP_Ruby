class CardholdersController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :authenticate, except: [:check_for_cardholder, :onboard, :complete_onboard]
  before_filter :find_venue, except: [:check_for_cardholder, :onboard, :complete_onboard]

  before_filter :find_card_level, only: [:batch_new, :batch_create, :bulk_import_form, :bulk_import]

  skip_authorization_check only: [:check_for_cardholder, :onboard, :complete_onboard]

  public_actions :onboard, :complete_onboard

  def index
    @card_levels = @venue.card_levels

    @cards = Card.for_venue(@venue.id).joins(:cardholder).order('cardholders.last_name ASC')

    authorize! :read, Card if @cards.empty?

    @cards.each do |card|
      authorize! :read, card
    end

    @approved_cards = @cards.approved
    @pending_cards = @cards.pending

    if params[:card_level_id].present?
      @approved_cards = @approved_cards.where(card_level_id: params[:card_level_id])
      @card_level_id = params[:card_level_id]
    end

    if params[:filter].present?
      search_string = "%#{params[:filter]}%"
      @approved_cards = @approved_cards.where('cardholders.last_name LIKE ?', search_string)
      @filter_string = params[:filter]
    end
  end

  def batch_new
    authorize! :create, @card_level.cards.build
  end

  def batch_create
    cardholders = params[:cardholders].map do |index, ch_attr|
      attrs = ch_attr.merge(cards_attributes: { '0' => { card_level_id: params[:card_level_id], issuer_id: current_user.id, issued_at: Time.zone.now } })
      create_cardholder_or_card attrs
    end

    cardholders.each do |cardholder|
      authorize! :create, cardholder.cards.last

      if cardholder.persisted?
        cardholder.save and SmsMailer.delay(retry: false).cardholder_new_card_sms(cardholder, @venue)
      else
        cardholder.save and SmsMailer.delay(retry: false).cardholder_onboarding_sms(cardholder, @venue)
      end
    end

    @problems = cardholders.select &:invalid?

    if @problems.empty?
      redirect_to venue_cardholders_path, notice: "#{pluralize(cardholders.count, 'card')} issued"
    else
      render 'redo_batch'
    end
  end

  def bulk_import_form
    authorize! :create, @card_level.cards.build
  end

  def bulk_import
    authorize! :create, @card_level.cards.build

    phone_number_string = params_for_bulk_import
    phone_numbers = phone_number_string.split(/\s+/).reject &:blank?

    unless phone_numbers.all? { |phone| phone.match /\d{10}/ }
      @phone_number_string = phone_numbers.join("\n")
      flash[:error] = "Non-phone-number found. Please check input and try again"
      render :bulk_import_form and return
    end

    existing_phone_numbers = @venue.cardholders.map &:phone_number

    old_numbers = phone_numbers & existing_phone_numbers

    @old_cards = @venue.cards.select { |card| old_numbers.include? card.cardholder.phone_number }

    new_numbers = phone_numbers - existing_phone_numbers

    cardholders = new_numbers.map do |phone_number|
      attrs = {
        phone_number: phone_number,
        cards_attributes: {
          '0' => {
            card_level_id: params[:card_level_id],
            issuer_id: current_user.id,
            issued_at: Time.zone.now
          }
        }
      }

      create_cardholder_or_card attrs
    end

    cardholders.each do |cardholder|
      authorize! :create, cardholder.cards.last

      if cardholder.persisted?
        cardholder.save and SmsMailer.delay(retry: false).cardholder_new_card_sms(cardholder, @venue)
      else
        cardholder.save and SmsMailer.delay(retry: false).cardholder_onboarding_sms(cardholder, @venue)
      end
    end

    @problems = cardholders.select &:invalid?
    @successes = cardholders - @problems
  end

  def check_for_cardholder
    if Cardholder.find_by_phone_number params[:phone_number]
      render json: { phone_number: params[:phone_number].to_s }
    else
      head :not_found
    end
  end

  def onboard
    @cardholder = Cardholder.find_by_onboarding_token params[:token]

    render :not_found and return unless @cardholder.present?
  end

  def complete_onboard
    @cardholder = Cardholder.find_by_onboarding_token params[:token]

    render :not_found and return unless @cardholder.present?

    if @cardholder.update_attributes params_for_cardholder_activation
      @cardholder.update_attributes onboarding_token: nil
      @cardholder.activate!
    else
      render :onboard
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
    @venue = Venue.includes(:card_levels, :cardholders).find(current_user.venue_id)
  end

  def find_card_level
    @card_level = @venue.card_levels.find params[:card_level_id]
  end

  def params_for_cardholder
    params.require(:cardholder).permit(:first_name, :last_name, :phone_number, cards_attributes: [:card_level_id, :issuer_id])
  end

  def params_for_cardholder_activation
    params.require(:cardholder).permit(:first_name, :last_name, :phone_number, :password, :password_confirmation, :photo, :photo_cache)
  end

  def params_for_bulk_import
    params.require(:phone_numbers)
  end
end
