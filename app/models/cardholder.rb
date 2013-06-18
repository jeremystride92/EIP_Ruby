class Cardholder < ActiveRecord::Base
  has_many :cards
  accepts_nested_attributes_for :cards

  has_many :venues, through: :cards

  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update
  validates :phone_number,
    presence: true,
    uniqueness: true,
    format: { with: /\A\d{10}\Z/, message: 'Please enter a 10-digit phone number, digits only.' }
end
