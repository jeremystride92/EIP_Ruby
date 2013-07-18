class Cardholder < ActiveRecord::Base
  STATUSES = %w(pending active).freeze

  has_secure_password

  has_many :cards, order: :status
  accepts_nested_attributes_for :cards

  has_many :venues, through: :cards

  mount_uploader :photo, CardholderImageUploader

  validates :first_name, presence: true, unless: :pending?
  validates :last_name, presence: true, unless: :pending?


  validates :password, length: { in: 6..255 }, allow_nil: true
  validates :phone_number,
    presence: true,
    uniqueness: true,
    numericality: true,
    length: { is: 10 }

  before_create do
    generate_token(:auth_token)
    generate_token(:onboarding_token)
  end

  before_validation :generate_unusable_password!, unless: proc { |cardholder| cardholder.password_digest || cardholder.password }

  before_validation :set_default_status

  def generate_unusable_password!
    self.password = self.password_confirmation = SecureRandom.random_bytes(16)
  end

  STATUSES.each do |status_code|
    define_method("#{status_code}?") do
      self.status == status_code
    end
  end

  def activate!
    update_attributes(status: 'active')
  end

  def has_card_for_venue?(venue)
    venues.include? venue
  end

  def photo_path
    photo.cached? ? "/carrierwave/#{photo.cache_name}" : photo.url
  end

  def international_phone_number
    "1#{phone_number}"
  end

  def display_name
    return phone_number unless first_name.present? || last_name.present?
    "#{first_name} #{last_name}"
  end

  private

  def set_default_status
    self.status ||= 'pending'
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Cardholder.exists?(column => self[column])
  end
end
