class Venue < ActiveRecord::Base
  has_many :users
  has_many :card_levels
  has_many :cards, through: :card_levels
  has_many :cardholders, through: :cards
  has_many :promotions

  mount_uploader :logo, ImageUploader

  validates :name, presence: true
  validates :phone,
    presence: true,
    numericality: true,
    length: { is: 10 }

  validates :location, presence: true
  validates :address1, presence: true
  validates :vanity_slug,
    uniqueness: { allow_blank: true },
    format: {
      with: /^(?=.*[a-z])[-\w]*$/i,
      allow_blank: true,
      message: "Use only letters, numbers, underscores and dashes. Must contain at least one letter"
      },
    length: { maximum: 75 }

  def vanity_url
    vanity_slug ? ('https://www.EIPiD.com/' + vanity_slug) : nil
  end

  def logo_path
    logo.cached? ? "/carrierwave/#{logo.cache_name}" : logo.url
  end

  def owners
    User.where(venue_id: id).select(&:venue_owner?)
  end

  def managers
    User.where(venue_id: id).select(&:venue_manager?)
  end

  def default_signup_card_level
    card_levels.where(default_signup_level: true).first
  end
end
