class TemporaryCardsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :find_venue, except: [:public_show]
  before_filter :find_temporary_card, only: [:destroy]
  before_filter :find_temporary_card_from_access_token, only: [:public_show]

  skip_authorization_check only: [:public_show]

  def index
    if params[:partner_id]
      find_partner
      cards = @partner.temporary_cards
    else
      cards = @venue.temporary_cards
    end

    @active_cards = cards.select &:active?

    authorize! :read, @active_cards.first || TemporaryCard

    @batch_issue_path = @partner.present? ? new_batch_venue_partner_temporary_cards_path(@partner) : new_batch_venue_temporary_cards_path
  end


  def batch_new
    @partner = params[:partner_id] ? find_partner : nil
    authorize! :create, (@partner ? @partner.temporary_cards.build: TemporaryCard)
    @cancel_path = @partner.present? ? venue_partner_temporary_cards_path(@partner) : venue_temporary_cards_path
    @benefits = []

  end

  def batch_create
    phone_numbers = params_for_batch_phones[:phones].values.map(&:values).flatten

    @partner = @venue.partners.find params[:batch][:partner]
    authorize! :create, @partner.temporary_cards.build

    cards = []
    Time.use_zone @venue.time_zone do
      cards = phone_numbers.map do |phone_number|
        card = @partner.temporary_cards.build params_for_temp_card.merge(phone_number: phone_number, issuer: current_user)
        card.tap { |card| card.expires_at = card.expires_at.end_of_day }
      end
    end

    cards.each do |card|
      card.save and SmsMailer.delay(retry: false).temp_card_sms(card, @venue, @partner)
    end

    @problems = cards.reject &:persisted?

    if @problems.present?
      render :batch_errors
    else
      redirect_to venue_partner_temporary_cards_path(@partner), notice: "#{pluralize cards.count, 'Temporary Card'} issued for #{@partner.name}."
    end
  end

  def destroy
    authorize! :destroy, @temporary_card
    partner = @temporary_card.partner

    @temporary_card.destroy

    redirect_to venue_partner_temporary_cards_path(partner), notice: 'Temporary Card deleted.'
  end

  def public_show
    render layout: 'temporary_card'
  end

  private

  def find_venue
    @venue = Venue.includes(partners: [:temporary_cards]).find current_user.venue_id
  end

  def find_partner
    @partner = @venue.partners.find params[:partner_id]
  end

  def find_temporary_card
    @temporary_card = @venue.temporary_cards.find params[:id]
  end

  def find_temporary_card_from_access_token
    @temporary_card = TemporaryCard.find_by_access_token params[:access_token]
  end

  def params_for_batch_phones
    params.require('batch').permit(phones: [:phone_number])
  end

  def params_for_temp_card
    params.require('batch').permit(:guest_count, :expires_at, benefits_attributes: [:description])
  end
end