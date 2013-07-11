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

  it { should validate_presence_of :time_zone }

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

    it "should not allow a slug of 'venue'" do
      venue.vanity_slug = "venue"
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
    it "should be a card_level belonging to the venue" do
      venue = create :venue
      default_card_level = create :card_level, venue: venue
      other_card_levels = create_list :card_level, 3

      venue.default_signup_card_level.venue.should == venue
    end
  end

  describe "#sender_number" do
    before do
      ENV['nexmo_default_sender'] = '11234567890'
    end

    subject { build :venue }

    context "with nexmo_number set" do
      before do
        subject.nexmo_number = '10987654321'
      end

      its(:sender_number) { should == '10987654321' }
    end

    context "without nexmo_number set" do
      its(:sender_number) { should == '11234567890' }
    end
  end

  describe "#set_all_card_level_guest_passes" do
    let(:venue) { create :venue }

    before do
      create_list :card_level, 2, venue: venue
    end

    it "should call set_all_card_guest_passes on each card_level" do
      venue.card_levels.reload.each do |card_level|
        card_level.should_receive :set_all_card_guest_passes
      end

      venue.set_all_card_level_guest_passes
    end
  end
end
