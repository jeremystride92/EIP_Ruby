class RedeemableBenefit < ActiveRecord::Base
  belongs_to :card

  validates :card, presence: true

  scope :redeemed, -> { where('redeemed_at IS NOT NULL') }

  include Expirable

  def redeem!(redemption_time = Time.current)
    self.redeemed_at = redemption_time
    save!
  end

  alias_method :old_inactive?, :inactive?

  def inactive?(now = Time.zone.now)
    self.redeemed_at? || old_inactive?(now)
  end
end
