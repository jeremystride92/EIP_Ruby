require 'spec_helper'

describe CardLevel do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:venue_id) }
  it { should validate_presence_of :theme }

  it { should belong_to :venue }
  it { should have_many :cards }
  it { should have_many :benefits }

  describe "Validations" do
    let(:card_level) { create :card_level }

    it "should ensure the theme is valid" do
      card_level.theme = 'blue'
      card_level.should_not be_valid

      card_level.theme = 'black'
      card_level.should be_valid
    end

    it "should be valid when created with nested benefits" do
      benefits = attributes_for_list :benefit, 3
      nested_card_level = create :card_level, benefits_attributes: benefits
      nested_card_level.should be_valid
    end
  end

  describe "default signup card level per venue" do
    context "when only card_level in venue" do
      let(:venue) { create :venue }
      subject { create :card_level, venue: venue }
      it { should be_default_signup_level }
    end

    context "when other card_levels for venue exist" do
      let!(:venue) { create :venue }
      let!(:other_card_level) { create :card_level, venue: venue, default_signup_level: true }
      let!(:other_venue_card_level) { create :card_level, default_signup_level: true }
      subject { create :card_level, venue: venue }

      it { should_not be_default_signup_level }

      it "should change other card_level for same venue to false when set" do
        expect{subject.default_signup_level=true; subject.save!}.to change{other_card_level.reload.default_signup_level?}.from(true).to(false)
      end
      it "should not change other card_level for different venue to false when set" do
        expect{subject.default_signup_level=true; subject.save!}.to_not change{other_venue_card_level.reload.default_signup_level?}
      end

    end
  end
end
