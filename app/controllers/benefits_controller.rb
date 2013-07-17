class BenefitsController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue
  before_filter :find_benefits

  skip_authorization_check

  def index
    tz = ActiveSupport::TimeZone[@venue.time_zone]
    @start_date = params[:start_date] ? tz.parse(params[:start_date]).beginning_of_day : tz.now.beginning_of_day
    @end_date = params[:end_date] ? tz.parse(params[:end_date]).end_of_day : tz.now.end_of_day
    @end_date = @start_date.end_of_day if @end_date < @start_date
  end

  private

  def find_venue
    @venue = Venue.includes(cards: [:benefits, :cardholder]).find(current_user.venue_id)
    @cards = @venue.cards
  end

  def find_benefits
  end

end
