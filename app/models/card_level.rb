class CardLevel < ActiveRecord::Base
  THEMES = %w(black gold platinum purple)
  belongs_to :venue
  has_many :cards
  has_many :benefits, as: :beneficiary, before_add: :ensure_benefits_beneficiary

  accepts_nested_attributes_for :benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }

  validates :name, presence: true, uniqueness: { scope: :venue_id }
  validates :theme, presence: true, inclusion: THEMES

  def ensure_benefits_beneficiary(benefit)
    benefit.beneficiary ||= self
  end
end
