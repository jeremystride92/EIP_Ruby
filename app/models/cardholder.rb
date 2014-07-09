class Cardholder < ActiveRecord::Base
  STATUSES = %w(pending active).freeze

  has_secure_password

  has_many :cards, order: :status, before_add: :ensure_cards_cardholder, dependent: :destroy
  accepts_nested_attributes_for :cards

  has_many :venues, through: :cards

  belongs_to :sourceable, polymorphic: true

  mount_uploader :photo, CardholderImageUploader

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :activated_at, presence: true


  validates :password, length: { is: 4 }, numericality: { only_integer: true }, allow_nil: true
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
    self.password_digest = SecureRandom.hex(16)
  end

  def generate_onboarding_token
    generate_token(:onboarding_token)
  end

  STATUSES.each do |status_code|
    define_method("#{status_code}?") do
      self.status == status_code
    end
  end

  def activate!(additional_params = {})
    update_attributes({status: 'active', activated_at: Time.zone.now, onboarding_token: nil}.merge(additional_params))
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

  def send_pin_reset_sms!
    generate_reset_token
    save

    send_pin_reset_sms
  end

  def generate_reset_token
    generate_token(:reset_token)
    self.reset_token_date = Time.current
  end

  def source_name
    if (sourceable_type.present?)
      source = sourceable_type.constantize.find(sourceable_id) if(sourceable_id)
      source.try(:name)
    end
  end

  def source_type
    sourceable_type.try(:gsub,"Venue","Kiosk")
  end

  private


  def send_pin_reset_sms
    SmsMailer.delay(retry: false).pin_reset_sms(self.id)
  end

  def set_default_status
    self.status ||= 'pending'
  end

  def ensure_cards_cardholder(card)
    card.cardholder ||= self
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Cardholder.exists?(column => self[column])
  end
end
