require 'email_validator'

class User < ActiveRecord::Base
  has_secure_password

  belongs_to :venue

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    email: true
  validates :password, presence: true,
                       length: { in: 6..255 },
                       on: :create

  include RoleModel
  roles_attribute :roles_mask
  roles :admin, :venue_owner, :venue_manager

  before_create { generate_token(:auth_token) }

  private

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
end
