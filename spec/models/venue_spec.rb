require 'spec_helper'

describe Venue do
  it { should validate_presence_of :name }
  it { should have_many :card_levels }
  it { should have_many(:cards).through(:card_levels) }
  it { should have_many(:cardholders).through(:cards) }
end
