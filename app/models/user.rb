require 'email_validator'

class User < ActiveRecord::Base
  has_secure_password

  belongs_to :venue

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    email: true
  validates :password, length: { in: 6..255 }, allow_nil: true
  validates :name, presence: true
  validates :roles, presence: true

  include RoleModel
  roles_attribute :roles_mask
  roles :venue_owner, :venue_manager

  before_create { generate_token(:auth_token) }


  def generate_unusable_password!
    self.password = self.password_confirmation = SecureRandom.random_bytes(16)
    generate_reset_token
  end

  def generate_reset_token
    generate_token(:reset_token)
    self.reset_token_date = Time.current
  end

  def send_activation_email
    PasswordResetMailer.delay.password_reset_email(self)
  end

  def send_password_reset_email!
    generate_reset_token
    save
    send_password_reset_email
  end

  def send_password_reset_email
    PasswordResetMailer.delay.password_reset_email(self)
  end

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
end
