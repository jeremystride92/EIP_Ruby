class Venue < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_many :card_levels
  has_many :cards, through: :card_levels
  has_many :cardholders, through: :cards

  validates :name, presence: true
  validates :phone, presence: true
  validates :location, presence: true
  validates :address1, presence: true
  validates :vanity_slug, uniqueness: { allow_nil: true }

  def vanity_url
    vanity_slug ? ('https://www.EIPid.com/' + vanity_slug) : nil
  end
end
