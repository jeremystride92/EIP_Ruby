class Cardholder < ActiveRecord::Base
  has_many :cards, order: :status
  accepts_nested_attributes_for :cards

  has_many :venues, through: :cards

  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update
  validates :phone_number,
    presence: true,
    uniqueness: true,
    numericality: true,
    length: { is: 10 }
end
