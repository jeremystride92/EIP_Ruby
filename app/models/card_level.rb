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
    uniqueness: { scope: [ :venue_id, :deleted_at ]}

  before_validation :ensure_sort_position

  around_destroy :update_sort_positions

  before_save :update_card_redeemable_benefit_allotments

  def benefit_change
    allowed_redeemable_benefits_count - allowed_redeemable_benefits_count_was
  end

  def update_card_redeemable_benefit_allotments
    if benefit_change != 0
      transaction do
        card_bene_allotments = cards.collect{|c| {card_id: c.id, allotment: c.redeemable_benefit_allotment}} 

        #expire active items
        self.redeemable_benefits.where("source='card_level' AND 
                                      (start_date IS NULL OR start_date <= ?) AND 
                                      (end_date IS NULL OR end_date >= ?)", Time.zone.now(), Time.zone.now())
          .update_all(end_date: Time.zone.now())

        #add new active items (in batches)
        rbenes = []
        batch_size = 1000
        cards.each do | card |
          if card.persisted?
            old_allotment = card_bene_allotments.select{|allot| allot[:card_id] == card.id}.first[:allotment]
            num = [old_allotment + benefit_change, 0].max
            num.times do |x|
              rbenes << RedeemableBenefit.new(source: :card_level, card: card)
            end

            if rbenes.size >= batch_size
              RedeemableBenefit.import rbenes 
              rbenes = []
            end
          end
        end
        RedeemableBenefit.import rbenes 
      end
    end
  end

  def selective_update_redeemable_benefit_allotments
    if reload_redeemable_benefits_daily
      cards.each do |card| 
        card.update_attributes redeemable_benefit_allotment: allowed_redeemable_benefits_count 
      end
    end
  end

  def reorder_to(new_position)

    transaction do
      levels = venue.card_levels.where("id != ?", id).to_a

      new_position = 1 if new_position < 1;
      new_position = levels.count + 1 if new_position > levels.count + 1

      levels.insert(new_position - 1, self)
      levels.each_with_index do |level, index|
        level.update_attribute :sort_position, index + 1 
      end
    end

  end

  def redeemable_benefit_title
    (redeemable_benefit_name || 'redeemable_benefit').titleize
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

  private

  def ensure_benefits_beneficiary(benefit)
    benefit.beneficiary ||= self
  end

  def ensure_sort_position
    if sort_position.nil?
      if venue.present?
        self.sort_position = (venue.card_levels.pluck(:sort_position).max || 0) + 1
      else
        self.sort_position = 1
      end
    end
  end

end
