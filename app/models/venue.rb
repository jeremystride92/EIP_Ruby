class Venue < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_many :card_levels
  has_many :cards, through: :card_levels
  has_many :cardholders, through: :cards

  mount_uploader :logo, ImageUploader

  validates :name, presence: true
  validates :phone, presence: true
  validates :location, presence: true
  validates :address1, presence: true
  validates :vanity_slug, uniqueness: { allow_nil: true }

  def vanity_url
    vanity_slug ? ('https://www.EIPiD.com/' + vanity_slug) : nil
  end

  def logo_path
    logo.cached? ? "/carrierwave/#{logo.cache_name}" : logo.url
  end
end