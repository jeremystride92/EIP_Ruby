class Cardholder < ActiveRecord::Base
  has_many :cards
  has_many :venues, through: :cards

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true
end
