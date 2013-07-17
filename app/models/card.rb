class Card < ActiveRecord::Base
  STATUSES = %w(active inactive pending)

  belongs_to :card_level, counter_cache: true
  belongs_to :cardholder
  belongs_to :issuer, class_name: User

  has_one :venue, through: :card_level
  has_many :benefits, as: :beneficiary, before_add: :ensure_benefits_beneficiary
  accepts_nested_attributes_for :benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }

  has_many :guest_passes
  accepts_nested_attributes_for :guest_passes, allow_destroy: true

  validates :guest_count,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :status,
    presence: true,
    inclusion: STATUSES

  validates :issuer, presence: true, unless: :pending?
  validates :card_level, presence: true
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

  def active?
    self.status == 'active'
  end

  def inactive?
    !active?
  end

  def pending?
    status == 'pending'
  end

  def total_guest_count
    active_pass_count = guest_passes.select(&:active?).count

    guest_count + active_pass_count
  end

  def checkin_guests!(count)
    if count > total_guest_count
      raise "Too many guests"
    end

    if count <= guest_count
      new_guest_count = count < guest_count
      count = 0
    else
      new_guest_count = 0
      count -= guest_count

      active_passes = guest_passes.select(&:active?)
    end


    transaction do
      update_attributes guest_count: new_guest_count

      if count > 0
        active_passes.take(count).each do |pass|
          pass.destroy
        end
      end
    end
  end

  def display_name
    "#{cardholder.try(:display_name)}'s \"#{card_level.try(:name)}\" card from #{venue.try(:name)}"
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
