class Cardholder < ActiveRecord::Base
  has_secure_password

  has_many :cards, order: :status
  accepts_nested_attributes_for :cards

  has_many :venues, through: :cards

  validates :first_name, presence: true, on: :update
  validates :last_name, presence: true, on: :update
  validates :password, length: { in: 6..255 }, allow_nil: true
  validates :phone_number,
    presence: true,
    uniqueness: true,
    numericality: true,
    length: { is: 10 }

  before_create { generate_token(:auth_token) }

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
end
