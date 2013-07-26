class Partner < ActiveRecord::Base
  belongs_to :venue

  has_many :temporary_cards, dependent: :destroy

  validates :name, presence: true

  validates :phone_number,
    numericality: { only_integer: true, allow_nil: true },
    length: { is: 10, allow_nil: true }

  def active_cards_count
    temporary_cards.count(&:active?)
  end

  def lifetime_cards_count
    temporary_cards.size
  end

end
