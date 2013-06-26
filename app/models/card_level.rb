class CardLevel < ActiveRecord::Base
  THEMES = %w(black gold platinum purple)
  belongs_to :venue
  has_many :cards
  has_many :benefits, as: :beneficiary, before_add: :ensure_benefits_beneficiary

  accepts_nested_attributes_for :benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }

  validates :name, presence: true, uniqueness: { scope: :venue_id }
  validates :theme, presence: true, inclusion: THEMES

  before_create :set_to_default_if_only_card_level_for_venue
  before_save :toggle_other_default_signup_levels, if: :default_signup_level?

  private

  def ensure_benefits_beneficiary(benefit)
    benefit.beneficiary ||= self
  end

  def set_to_default_if_only_card_level_for_venue
    self.default_signup_level = true unless other_card_levels_for_venue.count() > 0
  end

  def toggle_other_default_signup_levels
    other_card_levels_for_venue.
      where(:default_signup_level => true).
      first.try :update_column, :default_signup_level, false
  end

  def other_card_levels_for_venue
    clt = CardLevel.arel_table
    CardLevel.where(clt[:venue_id].eq(venue_id), clt[:id].not_eq(id))
  end
end
