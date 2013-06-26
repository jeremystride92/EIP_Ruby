require 'spec_helper'

describe Venue do
  it { should have_many :users }
  it { should have_many :card_levels }
  it { should have_many(:cards).through(:card_levels) }
  it { should have_many(:cardholders).through(:cards) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :location }
  it { should validate_presence_of :address1 }
  it { should validate_uniqueness_of :vanity_slug }

  it { should validate_presence_of :phone }
  it { should validate_numericality_of :phone }

  it "should validate length of phone" do
    venue = build :venue

    venue.phone = '123456789'
    venue.should_not be_valid

    venue.phone = '1234567890'
    venue.should be_valid

    venue.phone = '12345678901'
    venue.should_not be_valid
  end

  describe "User finders" do
    let(:venue)     { create :venue }
    let!(:owner1)   { create :venue_owner, venue: venue }
    let!(:owner2)   { create :venue_owner, venue: venue }
    let!(:manager1) { create :venue_manager, venue: venue }
    let!(:manager2) { create :venue_manager, venue: venue }

    describe "#owners" do
      subject { venue.owners }
      it { should =~ [owner1, owner2] }
    end

    describe "#managers" do
      subject { venue.managers }
      it { should =~ [manager1, manager2] }
    end
  end

  describe "#default_signup_card_level" do
    it "should be the proper card_level" do
      venue = create :venue
      default_card_level = create :card_level, venue: venue, default_signup_level: true
      other_card_levels = create_list :card_level, 3, venue: venue, default_signup_level: false

      venue.default_signup_card_level.should == default_card_level
    end
  end
end
