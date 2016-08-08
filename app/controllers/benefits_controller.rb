class BenefitsController < ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :authenticate
  before_filter :find_venue
  before_filter :find_card_level, only: [:issue_benefit_form, :issue_benefit]

  def index
    authorize! :read, Benefit

    tz = ActiveSupport::TimeZone[@venue.time_zone]
    @start_date = params[:start_date] ? tz.parse(params[:start_date]).to_date : tz.now.to_date
    @end_date = params[:end_date] ? tz.parse(params[:end_date]).to_date : tz.now.to_date
    @end_date = @start_date if @end_date < @start_date

    @benefits_by_date = {}
    (@start_date..@end_date).to_a.reverse.each do |date|
      @benefits_by_date[date] = []
      @cards.each do |card|
        active_benefits = Time.use_zone(tz) { card.benefits.select { |benefit| benefit.active_in_range? date.beginning_of_day, date.end_of_day } }
        if active_benefits.present?
          @benefits_by_date[date] << { cardholder_name: card.cardholder.display_name, active_benefits: active_benefits }
        end
      end
    end
  end

  def issue_benefit_form
    @promo_message = PromotionalMessage.new
    @benefit = @card_level.temporary_benefits.build
    authorize! :create, @benefit
  end

  def issue_benefit
    @benefit = @card_level.temporary_benefits.build(benefit_params).tap &:merge_datetime_fields

    authorize! :create, @benefit

    if @benefit.temporary? && Time.use_zone(@venue.time_zone) { @benefit.save }
      notice = 'Temporary benefits issued.'

      if promo_message_params[:message].present?
        cardholders = @card_level.cards.map(&:cardholder).uniq

        time = Time.zone.now
        cardholders.each do |cardholder|
          SmsMailer.delay_until(time, retry: false).cardholder_promotion_message(cardholder.id, @venue.id, promo_message_params[:message])
          time += (Constants::TextUsMsgDelay).seconds
        end

        notice += " #{pluralize cardholders.count, 'cardholder'} notified."
      end

      redirect_to venue_card_levels_path, notice: notice
    else
      flash[:error] = "Temporary benefit must have a start or end date." if @benefit.permanent?
      @promo_message = PromotionMessage.new message: promo_message_params[:message], card_levels: []
      render :issue_benefit_form
    end
  end

  def destroy
    @benefit = Benefit.find params[:id]
    authorize! :destroy, @benefit

    if @benefit.destroy
       flash[:notice] = "Benefit deleted."
    else
      flash[:error] = "Benefit could not be deleted because of an unknown error."
    end

    redirect_to :back
  end

  private

  def find_venue
    @venue = Venue.includes(:card_levels, cards: [:cardholder, benefits: { beneficiary: :card_level }]).find(current_user.venue_id)
    @cards = @venue.cards
  end

  def find_card_level
    @card_level = CardLevel.where(venue_id: @venue.id).includes(:permanent_benefits, :temporary_benefits).find params[:card_level_id]
  end

  def benefit_params
    params.require(:benefit).permit(:id, :description, :start_date_field, :start_time_field, :end_date_field, :end_time_field)
  end

  def promo_message_params
    params.require(:benefit).permit(:promotion_message).permit(:message)
  end
end
