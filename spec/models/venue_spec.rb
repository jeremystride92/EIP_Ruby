require 'spec_helper'

describe Venue do
  it { should have_many :users }
  it { should have_many(:card_levels).order('sort_position ASC')}
  it { should have_many(:cards).through(:card_levels) }
  it { should have_many(:cardholders).through(:cards) }
  it { should have_many(:promotions) }
  it { should have_many(:partners) }
  it { should have_many(:temporary_cards).through(:partners) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :location }
  it { should validate_presence_of :address1 }
  it { should validate_uniqueness_of :vanity_slug }

  it { should validate_presence_of :phone }
  it { should validate_numericality_of :phone }
  it { should ensure_length_of(:phone).is_equal_to(10) }

  it { should validate_presence_of :time_zone }
  it { should ensure_inclusion_of(:time_zone).in_array(ActiveSupport::TimeZone.us_zones.map(&:name)) }

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
    let(:default_number) { '11234567890' }

    before do

      ENV['nexmo_default_sender'] = default_number
    end

    subject { build :venue }

    context "with nexmo_number set" do
      let (:specific_number) { '10987654321' }
      
      before do
        
        subject.nexmo_number = specific_number
      end

      its(:sender_number) { should == specific_number }
    end

    context "without nexmo_number set" do
      its(:sender_number) { should == default_number }
    end

    context "with nexmo_number set to empty string" do
      before do
        subject.nexmo_number = ""
      end

      its (:sender_number) { should == default_number }
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
