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
  end
end
