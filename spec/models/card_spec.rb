require 'spec_helper'

describe Card do
  it { should belong_to :card_level }
  it { should belong_to :cardholder }
  it { should have_one(:venue).through(:card_level) }

  context 'when another card for the same cardholder, venue exists' do
    let(:old_card) { create :card }
    let(:new_card_level) { create :card_level, venue: old_card.venue }
    subject { build :card, cardholder: old_card.cardholder, card_level: new_card_level }

    it { should_not be_valid }
  end
end
