require 'spec_helper'

describe CardLevel do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:venue_id) }

  it { should validate_presence_of :venue }

  it { should validate_presence_of :redeemable_benefit_name }

  it { should validate_presence_of :daily_redeemable_benefit_allotment }
  it { should validate_numericality_of(:daily_redeemable_benefit_allotment).only_integer.is_greater_than_or_equal_to(0) }

  it { should validate_numericality_of(:sort_position).only_integer.is_greater_than_or_equal_to(1) }
  it { should validate_uniqueness_of(:sort_position).scoped_to(:venue_id) }

  it { should belong_to :venue }
  it { should belong_to :card_theme }

  it { should have_many :cards }
  it { should have_and_belong_to_many :promotions }

  it { should have_many :benefits }
  it { should accept_nested_attributes_for :benefits }
  it { should have_many :permanent_benefits }
  it { should accept_nested_attributes_for :permanent_benefits }
  it { should have_many :temporary_benefits }
  it { should accept_nested_attributes_for :temporary_benefits }

  describe "Validations" do
    it "should be valid when created with nested benefits" do
      benefits = attributes_for_list :benefit, 3
      nested_card_level = create :card_level, benefits_attributes: benefits
      nested_card_level.should be_valid
    end
  end

  describe "default sort_position" do
    let(:venue) { create :venue }
    context "when the venue has no other Card Levels" do
      subject { create :card_level, venue: venue }

      its(:sort_position) { should == 1 }
    end

    context "when the venue has other Card Levels" do
      let(:num_card_levels) { 3 }

      before do
        create_list :card_level, num_card_levels, venue: venue
      end

      subject { create :card_level, venue: venue }

      its(:sort_position) { should == num_card_levels + 1 }
    end
  end

  describe "#set_all_card_redeemable_benefit_allotments" do
    let(:card_level) { create :card_level, daily_redeemable_benefit_allotment: 5 }

    before do
      create_list :card, 2, card_level: card_level
    end

    it "should set all associated Cards' redeemable_benefit_allotments to the Card Level's daily count" do
      card_level.set_all_card_redeemable_benefit_allotments
      card_level.cards.reload.each do |card|
        card.redeemable_benefit_allotment.should == 5
      end
    end
  end

  describe "#reorder_to" do
    let(:venue) { create :venue }
    let(:card_levels) { (1..5).map { |n| create :card_level, sort_position: n, venue: venue } }

    context "when going nowhere" do
      it "does nothing" do
        card_level = card_levels[2]
        card_level.reorder_to 3

        card_levels.each &:reload
        card_levels.map(&:sort_position).should == [1, 2, 3, 4, 5]
      end
    end

    context "when moving down the list" do
      context "when moving past the bottom" do
        it "sets the order only as large as it needs to be" do
          card_level = card_levels[1]
          lambda { card_level.reorder_to 10}.should change{card_level.sort_position}.from(2).to(5)
        end
      end

      it "moves other affected records up the list" do
        card_level = card_levels[1]
        card_level.reorder_to 4

        card_levels.each &:reload
        card_levels.map(&:sort_position).should == [1, 4, 2, 3, 5]
      end
    end

    context "moving up the list" do
      context "when moving past the top" do
        it "sets the order 1" do
          card_level = card_levels[4]
          lambda { card_level.reorder_to -5}.should change{card_level.sort_position}.from(5).to(1)
        end
      end

      it "moves other affected records down the list" do
        card_level = card_levels[3]
        card_level.reorder_to 2

        card_levels.each &:reload
        card_levels.map(&:sort_position).should == [1, 3, 4, 2, 5]
      end
    end
  end

  describe "correcting sort_position on destroy" do
    let(:venue) { create :venue }
    let(:card_levels) { (1..5).map { |n| create :card_level, sort_position: n, venue: venue } }

    context "when destroying from the middle" do
      it "should update the sort_position on remaining Card Levels" do
        card_levels[2].destroy

        venue.card_levels.reload.map(&:sort_position).should == (1..4).to_a
      end
    end

    context "when destroying from the beginning" do
      it "should update the sort_position on remaining Card Levels" do
        card_levels[0].destroy

        venue.card_levels.reload.map(&:sort_position).should == (1..4).to_a
      end
    end

    context "when destroying from the end" do
      it "should update the sort_position on remaining Card Levels" do
        card_levels[4].destroy

        venue.card_levels.reload.map(&:sort_position).should == (1..4).to_a
      end
    end
  end

  describe "benefit lists" do
    let(:card_level) { create :card_level }
    let(:permanent_benefits) { create_list :benefit, 2, beneficiary: card_level }
    let(:temporary_benefits) { create_list :benefit, 2, beneficiary: card_level, start_date: Date.current }

    subject { card_level }

    its(:temporary_benefits) { should =~ temporary_benefits }

    its(:permanent_benefits) { should =~ permanent_benefits }

    its(:benefits) { should =~ temporary_benefits + permanent_benefits }
  end

  describe "card count" do
    let(:card_level_1) { create :card_level }
    let(:card_level_2) { create :card_level }

    let!(:card) { create :card, card_level: card_level_1 }

    context "on initialization" do
      before do
        card_level_1.reload
        card_level_2.reload
      end

      it "is correct" do
        card_level_1.cards.size.should == 1
        card_level_2.cards.size.should == 0
      end
    end

    context "when moving a card between card levels" do
      before do
        card.card_level = card_level_2
        card.save!

        card_level_1.reload
        card_level_2.reload
      end

      it "is correct after the move" do
        card_level_1.cards.size.should == 0
        card_level_2.cards.size.should == 1
      end
    end
  end

  describe "redeemable_benefit_title" do
    let(:card_level) { build :card_level }

    subject { card_level.redeemable_benefit_title }

    context "with a redeemable benefit name" do
      before do
        card_level.redeemable_benefit_name = 'benefit name'
      end

      it { should == 'Benefit Name' }
    end

    context "without a redeemable benefit name" do
      before do
        card_level.redeemable_benefit_name = nil
      end

      it { should == 'Redeemable Benefit' }
    end
  end
end
