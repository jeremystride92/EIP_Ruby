class Card < ActiveRecord::Base
  belongs_to :card_level, counter_cache: true
  belongs_to :cardholder
  belongs_to :issuer, class_name: User

  has_one :venue, through: :card_level

  validates :guest_count,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :issuer_id, presence: true

  after_initialize :set_default_guest_count

  validate :unique_card_per_cardholder_and_venue

  scope :for_venue, lambda { |venue_id|
    joins(:card_level)
    .where(card_levels: { venue_id: venue_id })
  }

  private

  def unique_card_per_cardholder_and_venue
    similar_cards = Card.joins(:card_level).where(cardholder_id: cardholder_id, card_levels: { venue_id: venue.id })
    similar_cards = similar_cards.where('cards.id != ?', id) if id
    conflict = similar_cards.exists?

    if conflict
      errors.add :base, 'User has a card for that venue.'
    end
  end

  def set_default_guest_count
    self.guest_count ||= 0
  end
end
