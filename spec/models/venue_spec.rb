require 'spec_helper'

describe Venue do
  it { should have_many :users }
  it { should have_many :card_levels }
  it { should have_many(:cards).through(:card_levels) }
  it { should have_many(:cardholders).through(:cards) }
  it { should have_many(:promotions) }

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

  describe "validate format of vanity_slug" do
    let(:venue) { build :venue }

    it "should allow capital and lowercase letters, underscores, dashes, and numbers" do
      venue.vanity_slug = '7hat_1ne-Place'
      venue.should be_valid
    end

    it "should not allow spaces" do
      venue.vanity_slug = 'that one place'
      venue.should_not be_valid
    end

    it "should not allow special symbols" do
      %w[! @ # $ % ^ & * + ? . , \\ | ` ~ : ' "].each do |character|
        venue.vanity_slug = "th#{character}toneplace"
        venue.should_not be_valid
      end
    end

    it "should not allow only numbers" do
      venue.vanity_slug = '7447161403'
      venue.should_not be_valid
    end

    it "should limit length to 75 characters" do
      venue.vanity_slug = 'a'*76
      venue.should_not be_valid
    end
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
