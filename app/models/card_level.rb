class CardLevel < ActiveRecord::Base
  THEMES = %w(black gold platinum purple)
  belongs_to :venue
  has_many :cards
  has_many :benefits, as: :beneficiary, before_add: :ensure_benefits_beneficiary

  accepts_nested_attributes_for :benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }

  validates :name, presence: true, uniqueness: { scope: :venue_id }
  validates :theme, presence: true, inclusion: THEMES
  validates :venue, presence: true
  validates :daily_guest_pass_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, presence: true

  def set_all_card_guest_passes
    cards.update_all(guest_count: daily_guest_pass_count)
  end

  private

  def ensure_benefits_beneficiary(benefit)
    benefit.beneficiary ||= self
  end
end
