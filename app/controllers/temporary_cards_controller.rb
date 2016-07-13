class TemporaryCardsController < ApplicationController
  include ActionView::Helpers::TextHelper

  PUBLIC_ACTIONS = [:public_show]

  before_filter :authenticate, except: PUBLIC_ACTIONS
  before_filter :find_venue, except: PUBLIC_ACTIONS
  before_filter :find_venue_by_vanity_slug, only: PUBLIC_ACTIONS
  before_filter :find_temporary_card, only: [:destroy]
  before_filter :find_temporary_card_from_access_token, only: [:public_show]

  skip_authorization_check only: PUBLIC_ACTIONS

  def index
    if params[:partner_id]
      find_partner
      cards = @partner.temporary_cards.includes(:venue, :benefits, :issuer)
    else
      cards = @venue.temporary_cards.includes(:partner, :benefits, :issuer)
    end

    @active_cards = cards.select &:active?

    authorize! :read, @active_cards.first || TemporaryCard

    @batch_issue_path = @partner.present? ? new_batch_venue_partner_temporary_cards_path(@partner) : new_batch_venue_temporary_cards_path
  end


  def batch_new

    @partner_locked = current_user.is_partner_account?
    if @partner_locked
      @partner = current_user.partner
    else
      @partner = find_partner
    end

    authorize! :create, (@partner ? @partner.temporary_cards.build: TemporaryCard)
    @cancel_path = @partner.present? ? venue_partner_temporary_cards_path(@partner) : venue_temporary_cards_path

    benefits_map = Partner.all.map do |partner|
      [partner.id, { default_redeemable_benefit_allotment: partner.default_redeemable_benefit_allotment, redeemable_benefit_name: (partner.redeemable_benefit_name || '').titleize.pluralize, benefits: partner.default_benefits.map { |benefit| { description: benefit } } }]
    end
    @benefits = Hash[benefits_map]

    @redeemable_benefit_allotment = (@partner.default_redeemable_benefit_allotment || 0) if @partner.present?
  end

  def batch_create
    phone_numbers = params_for_batch_phones[:phones].values.map(&:values).flatten

    @partner = current_user.get_partner { @venue.partners.find params[:batch][:partner] }

    authorize! :create, @partner.temporary_cards.build

    cards = []
    Time.use_zone @venue.time_zone do
      cards = phone_numbers.map do |phone_number|
        card = @partner.temporary_cards.build params_for_temp_card.merge(phone_number: phone_number, issuer: current_user)
        card.redeemable_benefit_allotment ||= @partner.default_redeemable_benefit_allotment
        card.tap do |card|
          card.expires_at = card.expires_at.try(:end_of_day)
        end
      end
    end

    cards.each do |card|

      # PK edits
      card.save and SmsMailer.temp_card_sms(card.id, @venue.id, @partner.id)
      #card.save and SmsMailer.delay(retry: false).temp_card_sms(card.id, @venue.id, @partner.id)

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
    if @temporary_card.expired?
      cookies.delete(:id_token) if cookies[:id_token]
      render layout: 'temporary_card', action: :expired and return
    end

    if @temporary_card.id_token
      render layout: 'temporary_card', action: :claimed and return unless cookies[:id_token] == @temporary_card.id_token
    elsif request.headers['HTTP_USER_AGENT'] != 'bitlybot'
      Rails.logger.debug "TEMP CARD CLAIMED BY USERAGENT #{request.headers['HTTP_USER_AGENT']}"
      cookies.permanent[:id_token] = @temporary_card.generate_id_token
      @temporary_card.save
    end

    render layout: 'temporary_card'
  end

  private

  def find_venue
    @venue = Venue.includes(:partners).find current_user.venue_id
  end

  def find_venue_by_vanity_slug
    @venue = Venue.find_by_vanity_slug! request.subdomain
  end

  def find_partner
    @partner = @venue.partners.find params[:partner_id] if params[:partner_id].present?
  end

  def find_temporary_card
    @temporary_card = @venue.temporary_cards.find params[:id]
  end

  def find_temporary_card_from_access_token
    @temporary_card = TemporaryCard.find_by_access_token! params[:access_token]
  end

  def params_for_batch_phones
    params.require('batch').permit(phones: [:phone_number])
  end

  def params_for_temp_card
    params.require('batch').permit(:redeemable_benefit_allotment, :expires_at, benefits_attributes: [:description])
  end
end
