class CardLevel < ActiveRecord::Base
  belongs_to :venue
  has_many :cards

  validates :name, presence: true, uniqueness: { scope: :venue_id }
end
