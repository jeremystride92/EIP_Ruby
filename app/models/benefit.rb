class Benefit < ActiveRecord::Base
  belongs_to :beneficiary, polymorphic: true

  validates :description, presence: true
  validates :beneficiary, presence: true, unless: Proc.new { |benefit| benefit.beneficiary && benefit.beneficiary.new_record? }

  include Expirable
end
