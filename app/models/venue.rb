class Venue < ActiveRecord::Base
  has_many :card_levels
  has_many :cards, through: :card_levels
  has_many :cardholders, through: :cards

  validates :name, presence: true
end
