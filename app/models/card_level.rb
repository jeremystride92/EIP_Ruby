class CardLevel < ActiveRecord::Base
  belongs_to :venue
  belongs_to :card_theme

  has_many :cards
  has_many :benefits, as: :beneficiary, before_add: :ensure_benefits_beneficiary
  has_many :temporary_benefits, as: :beneficiary, class_name: 'Benefit', before_add: :ensure_benefits_beneficiary, conditions: '(start_date IS NOT NULL) OR (end_date IS NOT NULL)'
  has_many :permanent_benefits, as: :beneficiary, class_name: 'Benefit', before_add: :ensure_benefits_beneficiary, conditions: '(start_date IS NULL) AND (end_date IS NULL)'
  has_many :redeemable_benefits, through: :cards
  has_many :card_levels_promotional_messages
  has_many :promotional_messages, through: :card_levels_promotional_messages, order: :send_date_time
  has_and_belongs_to_many :promotions

  accepts_nested_attributes_for :benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }
  accepts_nested_attributes_for :temporary_benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }
  accepts_nested_attributes_for :permanent_benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }

  validates :name, presence: true, uniqueness: { scope: :venue_id }
  validates :venue, presence: true
  validates :redeemable_benefit_name, presence: true
  validates :allowed_redeemable_benefits_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, presence: true
  validates :sort_position,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    uniqueness: { scope: :venue_id }

  before_validation :ensure_sort_position

  around_destroy :update_sort_positions

  before_save :update_card_redeemable_benefit_allotments

  def benefit_change
    allowed_redeemable_benefits_count - allowed_redeemable_benefits_count_was
  end

  def update_card_redeemable_benefit_allotments
      cards.each { |card| card.redeemable_benefit_allotment += benefit_change }
  end

  def selective_update_redeemable_benefit_allotments
    if reload_redeemable_benefits_daily
      cards.each do |card| 
        card.update_attributes redeemable_benefit_allotment: allowed_redeemable_benefits_count 
      end
    end
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

  def redeemable_benefit_title
    (redeemable_benefit_name || 'redeemable_benefit').titleize
  end

  private

  def ensure_benefits_beneficiary(benefit)
    benefit.beneficiary ||= self
  end

  def ensure_sort_position
    if sort_position.nil?
      if venue.present?
        self.sort_position = venue.card_levels.count + 1
      else
        self.sort_position = 1
      end
    end
  end

  def update_sort_positions
    deleted_position = self.sort_position
    affected_card_levels = venue.card_levels.select { |card_level| card_level.sort_position > deleted_position }

    yield

    affected_card_levels.each do |card_level|
      card_level.sort_position -= 1
      card_level.save
    end
  end

end
