require 'spec_helper'

describe Card do
  it { should belong_to :card_level }
  it { should belong_to :cardholder }
  it { should have_one(:venue).through(:card_level) }

  describe 'defaults' do
    subject { Card.new }

    its(:guest_count) { should == 0 }

    its(:status) { should == 'active' }
  end

  describe 'Validations' do
    subject { build :card }

    it { should validate_presence_of :guest_count }
    it { should validate_presence_of :card_level }
    it { should validate_numericality_of(:guest_count).only_integer }

    it 'should only allow positive integer guest_count' do
      subject.guest_count = -3
      subject.should_not be_valid
    end

    it { should validate_presence_of :status }

    it 'should only allow valid card statuses' do
      subject.status = 'active'
      subject.should be_valid

      subject.status = 'inactive'
      subject.should be_valid

      subject.status = 'pretty'
      subject.should_not be_valid
    end

    context 'when another card for the same cardholder & venue exists' do
      let(:old_card) { create :card }
      let(:new_card_level) { create :card_level, venue: old_card.venue }
      subject { build :card, cardholder: old_card.cardholder, card_level: new_card_level }

      it { should_not be_valid }
    end

    context 'when this card is saved' do
      subject { create :card }

      it { should be_valid }
    end
  end
end
