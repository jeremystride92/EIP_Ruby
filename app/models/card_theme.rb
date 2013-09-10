class CardTheme < ActiveRecord::Base
  belongs_to :venue

  validates :name,
    presence: true,
    uniqueness: { scope: :venue_id }
end
