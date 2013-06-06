class Card < ActiveRecord::Base
  belongs_to :card_level
  belongs_to :cardholder

  has_one :venue, through: :card_level

  validate :unique_card_per_cardholder_and_venue

  private

  def unique_card_per_cardholder_and_venue
    similar_cards = Card.joins(:card_level).where(cardholder_id: cardholder_id, card_levels: { venue_id: venue.id })
    similar_cards = similar_cards.where('cards.id != ?', id) if id
    conflict = similar_cards.exists?

    if conflict
      errors.add :base, 'User has a card for that venue.'
    end
  end
end
