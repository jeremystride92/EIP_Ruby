require 'spec_helper'

describe Card do
  it { should belong_to :card_level }
  it { should belong_to :cardholder }
  it { should have_one(:venue).through(:card_level) }
  it { should have_many :benefits }
  it { should have_many :guest_passes }

  describe 'defaults' do
    subject { Card.new }

    its(:guest_count) { should == 0 }

    its(:status) { should == 'active' }
  end

  describe 'Validations' do
    subject { build :card }

    it { should validate_presence_of :guest_count }
    it { should validate_presence_of :card_level }
    it { should validate_presence_of :cardholder }
    it { should validate_numericality_of(:guest_count).only_integer }

    it 'should only allow positive integer guest_count' do
      subject.guest_count = -3
      subject.should_not be_valid
    end

    it { should validate_presence_of :status }

    it 'should only allow valid card statuses' do
      Card::STATUSES.each do |status|
        subject.status = status
        subject.should be_valid
      end

      subject.status = 'pretty'
      subject.should_not be_valid
    end

    context 'when another card for the same cardholder & venue exists' do
      let(:old_card) { create :card }
      let(:new_card_level) { create :card_level, venue: old_card.venue }
      subject { build :card, cardholder: old_card.cardholder, card_level: new_card_level }

      it { should_not be_valid }
    end

    describe "pending cards" do
      context "when card has pending status" do
        subject { create :card, issuer: nil, status: 'pending' }

        it { should be_valid }
        it { should_not validate_presence_of :issuer }
      end

      %w[active inactive].each do |status|
        context "when card has an #{status} status" do
          let(:issuer) { build :venue_manager }
          subject { build :card, issuer: issuer, status: status }

          it { should validate_presence_of :issuer }
        end
      end
    end

    context 'when this card is saved' do
      subject { create :card }

      it { should be_valid }
    end

    it "should be valid when created with nested benefits" do
      benefits = attributes_for_list :benefit, 3
      nested_card = create :card, benefits_attributes: benefits
      nested_card.should be_valid
    end
  end

  describe '#total_guest_count' do
    let(:card) { create :card, guest_count: 1 }

    subject { card.total_guest_count }

    context "with an expired pass" do
      before do
        card.guest_passes.create end_date: 1.day.ago
      end

      it { should == 1 }
    end

    context "with an unstarted pass" do
      before do
        card.guest_passes.create start_date: 1.day.from_now
      end

      it { should == 1 }
    end

    context "with an active temporary pass" do
      before do
        card.guest_passes.create start_date: 1.day.ago, end_date: 1.day.from_now
      end

      it { should == 2 }
    end

    context "with an indefinite pass" do
      before do
        card.guest_passes.create start_date: nil, end_date: nil
      end

      it { should == 2 }
    end
  end

  describe "#checkin_guests!" do
    context "without any GuestPasses" do
      context "without any daily passes" do
        let(:card) { build :card, guest_count: 0 }

        it "should raise an exception and not expend passes" do
          lambda {
            lambda { card.checkin_guests! 1 }.should raise_error 'Too many guests'
          }.should_not change { card.guest_count }
        end
      end

      context "without enough daily passes" do
        let(:card) { build :card, guest_count: 3 }

        it "should raise an exception and not expend passes" do
          lambda {
            lambda { card.checkin_guests! 4 }.should raise_error 'Too many guests'
          }.should_not change { card.guest_count }
        end
      end

      context "with enough daily passes" do
        let(:card) { build :card, guest_count: 3 }

        it "should subtract the checkins from the pass count" do
          card.checkin_guests! 2
          card.guest_count.should == 1
          card.total_guest_count.should == 1
        end
      end
    end

    context "with GuestPasses" do
      context "without any daily passes" do
        context "without enough GuestPasses" do
          let(:card) { create :card, guest_count: 0 }

          before do
            3.times do
              card.guest_passes.create
            end
          end

          it "should raise an exception and not expend passes" do
            lambda {
              lambda {
                lambda {card.checkin_guests! 4}.should raise_error "Too many guests"
              }.should_not change { card.guest_count }
            }.should_not change { card.guest_passes.count }
          end
        end

        context "with enough GuestPasses" do
          let(:card) { create :card, guest_count: 0 }

          before do
            3.times do
              card.guest_passes.create
            end
          end

          it "should remove the right number of GuestPasses" do
            card.checkin_guests! 2
            card.guest_count.should == 0
            card.guest_passes.count.should == 1
            card.reload.total_guest_count.should == 1
          end
        end
      end

      context "without enough daily passes" do
        context "without enough GuestPasses" do
          let(:card) { create :card, guest_count: 3 }

          before do
            3.times do
              card.guest_passes.create
            end
          end

          it "should raise an exception and not expend passes" do
            lambda {
              lambda {
                lambda {card.checkin_guests! 8}.should raise_error "Too many guests"
              }.should_not change { card.guest_count }
            }.should_not change { card.guest_passes.count }
          end
        end

        context "with enough GuestPasses" do
          let(:card) { create :card, guest_count: 1 }

          before do
            3.times do
              card.guest_passes.create
            end
          end

          it "should remove the right number of GuestPasses" do
            card.checkin_guests! 2
            card.guest_count.should == 0
            card.guest_passes.count.should == 2
            card.reload.total_guest_count.should == 2
          end
        end
      end

      context "with enough daily passes" do
        let(:card) { create :card, guest_count: 3 }

        before do
          3.times do
            card.guest_passes.create
          end
        end

        it "should use only daily passes" do
          card.checkin_guests! 2
          card.guest_count.should == 1
          card.guest_passes.count.should == 3
          card.total_guest_count.should == 4
        end
      end
    end
  end
end
