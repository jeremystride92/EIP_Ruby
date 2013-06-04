class Cardholder < ActiveRecord::Base

  attr_accessible :first_name, :last_name, :phone_number, :photo
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true

end
