class TemporaryCardsController < ApplicationController
  include ActionView::Helpers::TextHelper

  PUBLIC_ACTIONS = [:public_show, :expired, :claimed]

  before_filter :authenticate, except: PUBLIC_ACTIONS
  before_filter :find_venue, except: PUBLIC_ACTIONS
  before_filter :find_venue_by_vanity_slug, only: PUBLIC_ACTIONS
  before_filter :find_temporary_card, only: [:destroy]
  before_filter :find_temporary_card_from_access_token, only: [:public_show]

  skip_authorization_check only: PUBLIC_ACTIONS

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

    benefits_map = Partner.all.map do |partner|
      [partner.id, { default_guest_count: partner.default_guest_count, benefits: partner.default_benefits.map { |benefit| { description: benefit } } }]
    end
    @benefits = Hash[benefits_map]

    @guest_count = (@partner.default_guest_count || 0) if @partner.present?
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
    redirect_to :expired_temporary_card and return if @temporary_card.expired?

    if @temporary_card.id_token
      redirect_to :claimed_temporary_card and return unless cookies[:id_token] == @temporary_card.id_token
    else
      cookies.permanent[:id_token] = @temporary_card.generate_id_token
      @temporary_card.save
    end

    render layout: 'temporary_card'
  end

  def expired
    cookies.delete(:id_token) if cookies[:id_token]
    render layout: 'temporary_card'
  end

  def claimed
    render layout: 'temporary_card'
  end
  private

  def find_venue
    @venue = Venue.includes(partners: [:temporary_cards]).find current_user.venue_id
  end

  def find_venue_by_vanity_slug
    @venue = Venue.find_by_vanity_slug! request.subdomain
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
