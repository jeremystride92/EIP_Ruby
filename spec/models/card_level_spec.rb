require 'spec_helper'

describe CardLevel do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:venue_id) }

  it { should validate_presence_of :theme }
  it { should ensure_inclusion_of(:theme).in_array(CardLevel::THEMES) }

  it { should validate_presence_of :venue }

  it { should validate_presence_of :daily_guest_pass_count }
  it { should validate_numericality_of(:daily_guest_pass_count).only_integer.is_greater_than_or_equal_to(0) }

  it { should validate_presence_of :sort_position }
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
end
