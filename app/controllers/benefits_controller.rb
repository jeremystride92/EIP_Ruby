class BenefitsController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue
  before_filter :find_benefits

  skip_authorization_check

  def index

  end

  private

  def find_venue
    @venue = Venue.includes(cards: [:benefits, :cardholder]).find(current_user.venue_id)
    @cards = @venue.cards
  end

  def find_benefits
  end

end
