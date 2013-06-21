class Card < ActiveRecord::Base
  STATUSES = %w(active inactive)

  belongs_to :card_level, counter_cache: true
  belongs_to :cardholder
  belongs_to :issuer, class_name: User

  has_one :venue, through: :card_level
  has_many :benefits, as: :beneficiary, before_add: :ensure_benefits_beneficiary
  accepts_nested_attributes_for :benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }

  validates :guest_count,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :issuer_id, presence: true

  validates :status,
    presence: true,
    inclusion: STATUSES

  validates :card_level, presence: true
  validate :unique_card_per_cardholder_and_venue

  after_initialize :set_defaults

  scope :for_venue, lambda { |venue_id|
    joins(:card_level)
    .where(card_levels: { venue_id: venue_id })
  }

  scope :active, where(status: 'active')
  scope :inactive, where(status: 'inactive')

  def active?
    self.status == 'active'
  end

  def inactive?
    !active?
  end

  private

  def unique_card_per_cardholder_and_venue
    return unless card_level_id

    similar_cards = Card.joins(:card_level).where(cardholder_id: cardholder_id, card_levels: { venue_id: venue.id })
    similar_cards = similar_cards.where('cards.id != ?', id) if id
    conflict = similar_cards.exists?

    if conflict
      errors.add :base, 'This person already has a card for this venue.'
    end
  end

  def ensure_benefits_beneficiary(benefit)
    benefit.beneficiary ||= self
  end

  def set_defaults
    self.guest_count ||= 0
    self.status ||= 'active'
  end
end
