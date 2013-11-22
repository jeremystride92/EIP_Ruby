class Card < ActiveRecord::Base
  STATUSES = %w(active inactive pending)

  belongs_to :card_level
  belongs_to :cardholder
  belongs_to :issuer, class_name: User

  has_one :venue, through: :card_level
  has_many :benefits, as: :beneficiary, before_add: :ensure_benefits_beneficiary, dependent: :destroy
  accepts_nested_attributes_for :benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }

  has_many :redeemable_benefits
  accepts_nested_attributes_for :redeemable_benefits, allow_destroy: true

  validates :status,
    presence: true,
    inclusion: STATUSES
  validates :redeemable_benefit_allotment,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :issuer, presence: true, unless: :pending?
  validates :card_level, presence: true
  validates :cardholder, presence: true
  validates :issued_at, presence: true, unless: :pending?
  validate :unique_card_per_cardholder_and_venue

  after_initialize :set_defaults

  scope :for_venue, lambda { |venue_id|
    joins(:card_level)
    .where(card_levels: { venue_id: venue_id })
  }

  scope :active, where(status: 'active')
  scope :inactive, where(status: 'inactive') # this excludes pending cards as well as active cards

  scope :pending, where(status: 'pending')
  scope :approved, where(Card.arel_table[:status].not_eq('pending'))

  delegate :source_name, :source_type , to: :cardholder

  def active?
    self.status == 'active' && self.card_level.deleted_at.nil?
  end

  def inactive?
    !active?
  end

  def pending?
    status == 'pending'
  end

  def activated_at
    unless pending?
      (cardholder.activated_at > issued_at) ? cardholder.activated_at : issued_at
    end
  end

  def redeemable_benefit_allotment
    self.redeemable_benefits.where(source: :card_level).select(&:active?).count
  end

  def redeemable_benefit_allotment= (num)

    transaction do
      #expire active items
      self.redeemable_benefits.where(source: :card_level).select(&:active?).each(&:expire!)

      num = [num, 0].max
      #add new active items
      self.redeemable_benefits.build ([{ source: :card_level, card: self }] * num)
      self.redeemable_benefits.each &:save! if persisted?

    end

  end

  def total_redeemable_benefit_allotment
    active_benefits_count = redeemable_benefits.select(&:active?).count
  end

  def redeem_benefits!(count)

    count = [count, 0].max # => ensure count is non-negative

    if count > total_redeemable_benefit_allotment
      raise "Too few benefits"
    end
    
    active_benefits = redeemable_benefits.select(&:active?)

    active_benefits.sort_by! { |b| b.end_date.nil? ? Time.zone.at(9999999999) : b.end_date }

    transaction do
      active_benefits.take(count).each &:redeem!
    end
    
  end

  def display_name
    "#{cardholder.display_name}'s \"#{card_level.name}\" card from #{venue.name}"
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

  def redeemable_benefits_from_card_level
    self.redeemable_benefits.where(source: :card_level).count
  end

  def set_defaults
    self.status ||= 'active'
  end
end
