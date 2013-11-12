class RedeemableBenefit < ActiveRecord::Base
  belongs_to :card

  validates :card, presence: true

  scope :redeemed, -> { where('redeemed_at IS NOT NULL') }

  include Expirable

  DEFAULTS = {
    source: 'card'
  }

  def initialize(*args)
    super DEFAULTS.merge(args[0]||{})
  end

  def redeem(redemption_time = Time.current)
    self.redeemed_at = redemption_time
  end

  def redeem!(redemption_time = Time.current)
    redeem
    save!
  end

  alias_method :old_inactive?, :inactive?

  def inactive?(now = Time.zone.now)
    self.redeemed? || old_inactive?(now)
  end

  def redeemed?
    self.redeemed_at?
  end

end
