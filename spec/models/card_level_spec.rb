require 'spec_helper'

describe CardLevel do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:venue_id) }

  it { should validate_presence_of :theme }
  it { should ensure_inclusion_of(:theme).in_array(CardLevel::THEMES) }

  it { should validate_presence_of :venue }

  it { should validate_presence_of :daily_guest_pass_count }
  it { should validate_numericality_of(:daily_guest_pass_count).only_integer.is_greater_than_or_equal_to(0) }

  it { should validate_numericality_of(:sort_position).only_integer.is_greater_than_or_equal_to(1) }
  it { should validate_uniqueness_of(:sort_position).scoped_to(:venue_id) }

  it { should belong_to :venue }
  it { should have_many :cards }
  it { should have_many :benefits }
  it { should have_and_belong_to_many :promotions }

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

  describe "#set_all_card_guest_passes" do
    let(:card_level) { create :card_level, daily_guest_pass_count: 5 }

    before do
      create_list :card, 2, card_level: card_level
    end

    it "should set all associated Cards' guest_count to the Card Level's daily count" do
      card_level.set_all_card_guest_passes
      card_level.cards.reload.each do |card|
        card.guest_count.should == 5
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
end
