require 'spec_helper'

describe Venue do
  it { should have_many :users }
  it { should have_many(:card_levels).order('sort_position ASC')}
  it { should have_many(:cards).through(:card_levels) }
  it { should have_many(:cardholders).through(:cards) }
  it { should have_many(:promotions) }
  it { should have_many(:partners) }
  it { should have_many(:temporary_cards).through(:partners) }
  it { should have_many(:card_themes) }

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

  describe "#update_reloadable_benefits" do
    let(:venue) { create :venue }

    let!(:reset_card_level) { create :card_level, venue: venue, reload_redeemable_benefits_daily: true, allowed_redeemable_benefits_count: 3 }
    let!(:unreset_card_level) { create :card_level, venue: venue, reload_redeemable_benefits_daily: false, allowed_redeemable_benefits_count: 3 }

    let!(:reset_card) { create :card, redeemable_benefit_allotment: 1, card_level: reset_card_level }
    let!(:unreset_card) { create :card, redeemable_benefit_allotment: 1, card_level: unreset_card_level }

    it "should reset card allotment levels on each card on any card_level that is reset daily" do

      venue.card_levels.reload

      venue.update_reloadable_benefits

      reset_card.reload.redeemable_benefit_allotment.should == 3
      unreset_card.reload.redeemable_benefit_allotment.should == 1

    end
  end
end
