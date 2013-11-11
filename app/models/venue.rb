class Venue < ActiveRecord::Base
  has_many :users
  has_many :card_levels, order: 'sort_position ASC'
  has_many :cards, through: :card_levels
  has_many :cardholders, through: :cards
  has_many :promotions
  has_many :partners
  has_many :temporary_cards, through: :partners
  has_many :card_themes

  mount_uploader :logo, LogoImageUploader
  mount_uploader :kiosk_background, KioskBackgroundUploader

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
    length: { maximum: 75 },
    exclusion: { in: %w(venue) }

    validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.zones_map(&:name), message: "Not a valid time zone" }

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
    card_levels.first
  end

  def sender_number
    nexmo_number.blank? ? ENV['nexmo_default_sender'] : nexmo_number
  end

  def set_all_card_level_redeemable_benefit_allotments
    card_levels.where(reload_redeemable_benefits_daily: true).each do |card_level|
      card_level.set_all_card_redeemable_benefit_allotments
    end
  end
end
