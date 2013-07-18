class CardLevel < ActiveRecord::Base
  THEMES = %w(black gold platinum purple)
  belongs_to :venue
  has_many :cards
  has_many :benefits, as: :beneficiary, before_add: :ensure_benefits_beneficiary
  has_and_belongs_to_many :promotions

  accepts_nested_attributes_for :benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }

  validates :name, presence: true, uniqueness: { scope: :venue_id }
  validates :theme, presence: true, inclusion: THEMES
  validates :venue, presence: true
  validates :daily_guest_pass_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, presence: true
  validates :sort_position,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    uniqueness: { scope: :venue_id },
    presence: true

  def set_all_card_guest_passes
    cards.update_all(guest_count: daily_guest_pass_count)
  end

  def reorder_to(new_position)
    card_levels = self.venue.card_levels.order(:sort_position)

    old_position = self.sort_position

    new_position = card_levels.count if new_position > card_levels.count
    new_position = 1 if new_position < 1

    transaction do

      if old_position == new_position
        return
      elsif old_position < new_position
        ((old_position + 1)..new_position).each do |i|
          card_levels[i - 1].sort_position -= 1
        end

        self.update_attribute(:sort_position, 0)
        card_levels[(old_position..(new_position - 1))].each &:save!
      else
        (new_position..(old_position - 1)).each do |i|
          card_levels[i - 1].sort_position += 1
        end

        self.update_attribute(:sort_position, 0)
        card_levels[((new_position - 1)..(old_position - 2))].reverse.each &:save!
      end

      self.update_attributes(sort_position: new_position)
    end
  end

  private

  def ensure_benefits_beneficiary(benefit)
    benefit.beneficiary ||= self
  end
end
