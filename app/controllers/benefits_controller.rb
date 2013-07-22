class BenefitsController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue

  def index
    authorize! :read, Benefit

    tz = ActiveSupport::TimeZone[@venue.time_zone]
    @start_date = params[:start_date] ? tz.parse(params[:start_date]).to_date : tz.now.to_date
    @end_date = params[:end_date] ? tz.parse(params[:end_date]).to_date : tz.now.to_date
    @end_date = @start_date if @end_date < @start_date

    @benefits_by_date = {}
    (@start_date..@end_date).each do |date|
      @benefits_by_date[date] = []
      @cards.each do |card|
        active_benefits = Time.use_zone(tz) { card.benefits.select { |benefit| benefit.active_in_range? date.beginning_of_day, date.end_of_day } }
        if active_benefits.present?
          @benefits_by_date[date] << { cardholder_name: card.cardholder.display_name, active_benefits: active_benefits }
        end
      end
    end
  end

  private

  def find_venue
    @venue = Venue.includes(cards: [:benefits, :cardholder]).find(current_user.venue_id)
    @cards = @venue.cards
  end
end
