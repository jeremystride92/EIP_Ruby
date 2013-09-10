class Partner < ActiveRecord::Base
  belongs_to :venue
  belongs_to :card_theme

  has_many :temporary_cards, dependent: :destroy

  validates :name, presence: true

  validates :phone_number,
    numericality: { only_integer: true, allow_nil: true },
    length: { is: 10, allow_nil: true }

  validates :default_guest_count,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  serialize :default_benefits, JSON

  before_save { self.default_benefits ||= [] }

  def active_cards_count
    temporary_cards.select(&:active?).count
  end

  def lifetime_cards_count
    temporary_cards.size
  end
end
