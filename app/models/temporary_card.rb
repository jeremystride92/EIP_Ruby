class TemporaryCard < ActiveRecord::Base
  belongs_to :partner
  belongs_to :issuer, class_name: User

  has_one :venue, through: :partner
  has_many :benefits, as: :beneficiary, before_add: :ensure_benefits_beneficiary
  accepts_nested_attributes_for :benefits, allow_destroy: true, reject_if: proc { |attrs| attrs[:description].blank? }

  validates :expires_at, presence: true

  validates :phone_number,
    numericality: { only_integer: true, allow_nil: true },
    length: { is: 10, allow_nil: true }

  validates :redeemable_benefit_allotment,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_create { generate_token :access_token }

  def expired?(date = Time.zone.now)
    expires_at < date
  end

  def active?(date = Time.zone.now)
    !expired? date
  end

  def international_phone_number
    "1#{phone_number}"
  end

  def display_name
    "#{phone_number} via #{partner.name} to #{venue.name}"
  end

  def generate_id_token
    generate_token(:id_token)

    self.id_token
  end

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while TemporaryCard.exists?(column => self[column])
  end

  def ensure_benefits_beneficiary(benefit)
    benefit.beneficiary ||= self
  end
end
