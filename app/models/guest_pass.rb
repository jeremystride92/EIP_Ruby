class GuestPass < ActiveRecord::Base
  belongs_to :card

  validates :card, presence: true

  include Expirable
end