require 'spec_helper'

describe Venue do
  it { should have_many :card_levels }
  it { should have_many(:cards).through(:card_levels) }
  it { should have_many(:cardholders).through(:cards) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :phone }
  it { should validate_presence_of :location }
  it { should validate_presence_of :address1 }
  it { should validate_uniqueness_of :vanity_slug }
end
