require 'email_validator'

class User < ActiveRecord::Base
  has_secure_password

  belongs_to :venue
  belongs_to :partner

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    email: true
  validates :password, length: { in: 6..255 }, allow_nil: true
  validates :name, presence: true
  validates :roles, presence: true
  validates :partner, presence: true, if: -> { has_role?(:venue_partner) }

  include RoleModel
  roles_attribute :roles_mask
  roles :venue_owner, :venue_manager, :site_admin, :venue_partner

  before_create { generate_token(:auth_token) }

  def self.valid_venue_roles
    valid_roles.select{ |role| role.to_s =~ /venue/i }
  end


  def generate_unusable_password!
    self.password = self.password_confirmation = SecureRandom.random_bytes(16)
    generate_reset_token
  end

  def generate_reset_token
    generate_token(:reset_token)
    self.reset_token_date = Time.current
  end

  def send_activation_email
    # PK Edits
    # BusinessOnboardMailer.delay(retry: false).onboard_email(self.id)
    BusinessOnboardMailer.onboard_email(self.id)
  end

  def send_password_reset_email!
    generate_reset_token
    save
    send_password_reset_email
  end

  def send_password_reset_email
    # PK Edits
    # PasswordResetMailer.delay(retry: false).password_reset_email(self.id)
    PasswordResetMailer.password_reset_email(self.id)
  end

  def is_partner_account?
    partner.present? && is_exactly?(:venue_partner)
  end

  def get_partner
    if is_partner_account?
      partner
    elsif block_given?
      yield
    end
  end

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

end
