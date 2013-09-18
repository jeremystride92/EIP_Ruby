require 'spec_helper'

describe Card do
  it { should belong_to :card_level }
  it { should belong_to :cardholder }
  it { should have_one(:venue).through(:card_level) }
  it { should have_many :benefits }
  it { should have_many :redeemable_benefits }

  describe 'defaults' do
    subject { Card.new }

    its(:redeemable_benefit_allotment) { should == 0 }

    its(:status) { should == 'active' }
  end

  describe 'Validations' do
    subject { build :card }

    it { should validate_presence_of :redeemable_benefit_allotment }
    it { should validate_presence_of :card_level }
    it { should validate_presence_of :cardholder }
    it { should validate_numericality_of(:redeemable_benefit_allotment).only_integer.is_greater_than_or_equal_to(0) }

    %w[active inactive].each do |status|
      context "when #{status}" do
        subject {create :card, status: status }

        it { should validate_presence_of :issued_at }
      end
    end

    context "when pending" do
      subject {create :pending_card }

      it { should_not validate_presence_of :issued_at }
    end

    it 'should only allow positive integer redeemable_benefit_allotment' do
      subject.redeemable_benefit_allotment = -3
      subject.should_not be_valid
    end

    it { should validate_presence_of :status }
    it { should ensure_inclusion_of(:status).in_array(Card::STATUSES) }

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

  describe '#activated_at' do
    context "when card issued before cardholder activated" do
      let(:issued_time) { Time.zone.now }
      let(:activated_time) { issued_time + 2.days }
      let(:card) { create :card, cardholder: cardholder, issued_at: issued_time }
      let(:cardholder) { create :cardholder, activated_at: activated_time }

      subject { card.activated_at }

      it { should == activated_time }
    end

    context "when card issued to cardholder with previously active account" do
      let(:issued_time) { Time.zone.now }
      let(:activated_time) { issued_time - 2.days }
      let(:card) { create :card, cardholder: cardholder, issued_at: issued_time }
      let(:cardholder) { create :cardholder, activated_at: activated_time }

      subject { card.activated_at }

      it { should == issued_time }
    end

    context "when card is pending" do
      let(:activated_time) { Time.zone.now - 2.days }
      let(:card) { create :pending_card, cardholder: cardholder}
      let(:cardholder) { create :cardholder, activated_at: activated_time }

      subject { card.activated_at }

      it { should be_nil }
    end
  end

  describe '#total_redeemable_benefit_allotment' do
    let(:card) { create :card, redeemable_benefit_allotment: 1 }

    subject { card.total_redeemable_benefit_allotment }

    context "with an expired redeemable benefit" do
      before do
        card.redeemable_benefits.create end_date: 1.day.ago
      end

      it { should == 1 }
    end

    context "with an unstarted redeemable benefit" do
      before do
        card.redeemable_benefits.create start_date: 1.day.from_now
      end

      it { should == 1 }
    end

    context "with an active temporary redeemable benefit" do
      before do
        card.redeemable_benefits.create start_date: 1.day.ago, end_date: 1.day.from_now
      end

      it { should == 2 }
    end

    context "with an indefinite redeemable benefit" do
      before do
        card.redeemable_benefits.create start_date: nil, end_date: nil
      end

      it { should == 2 }
    end
  end

  describe "#redeem_benefits!" do
    context "without any RedeemableBenefits" do
      context "without any daily redeemable benefits" do
        let(:card) { build :card, redeemable_benefit_allotment: 0 }

        it "should raise an exception and not expend redeemable benefits" do
          lambda {
            lambda { card.redeem_benefits! 1 }.should raise_error 'Too few benefits'
          }.should_not change { card.redeemable_benefit_allotment }
        end
      end

      context "without enough daily redeemable benefits" do
        let(:card) { build :card, redeemable_benefit_allotment: 3 }

        it "should raise an exception and not expend redeemable benefits" do
          lambda {
            lambda { card.redeem_benefits! 4 }.should raise_error 'Too few benefits'
          }.should_not change { card.redeemable_benefit_allotment }
        end
      end

      context "with enough daily redeemable benefits" do
        let(:card) { build :card, redeemable_benefit_allotment: 5 }

        it "should subtract the redemptions from the redeemable benefit count" do
          card.redeem_benefits! 2
          card.redeemable_benefit_allotment.should == 3
          card.total_redeemable_benefit_allotment.should == 3
        end
      end
    end

    context "with RedeemableBenefits" do
      context "without any daily benefits" do
        context "without enough RedeemableBeenfits" do
          let(:card) { create :card, redeemable_benefit_allotment: 0 }

          before do
            3.times do
              card.redeemable_benefits.create
            end
          end

          it "should raise an exception and not expend redeemable benefits" do
            lambda {
              lambda {
                lambda {card.redeem_benefits! 4}.should raise_error "Too few benefits"
              }.should_not change { card.redeemable_benefit_allotment }
            }.should_not change { card.redeemable_benefits.count }
          end
        end

        context "with enough RedeemableBenefits" do
          let(:card) { create :card, redeemable_benefit_allotment: 0 }

          before do
            3.times do
              card.redeemable_benefits.create
            end
          end

          it "should remove the right number of RedeemableBenefits" do
            card.redeem_benefits! 2
            card.redeemable_benefit_allotment.should == 0
            card.redeemable_benefits.count.should == 1
            card.reload.total_redeemable_benefit_allotment.should == 1
          end
        end
      end

      context "without enough daily redeemable benefits" do
        context "without enough RedeemableBenefits" do
          let(:card) { create :card, redeemable_benefit_allotment: 3 }

          before do
            3.times do
              card.redeemable_benefits.create
            end
          end

          it "should raise an exception and not expend redeemable benefits" do
            lambda {
              lambda {
                lambda {card.redeem_benefits! 8}.should raise_error "Too few benefits"
              }.should_not change { card.redeemable_benefit_allotment }
            }.should_not change { card.redeemable_benefits.count }
          end
        end

        context "with enough RedeemableBenefits" do
          let(:card) { create :card, redeemable_benefit_allotment: 1 }

          before do
            3.times do
              card.redeemable_benefits.create
            end
          end

          it "should remove the right number of RedeemableBenefits" do
            card.redeem_benefits! 2
            card.redeemable_benefit_allotment.should == 0
            card.redeemable_benefits.count.should == 2
            card.reload.total_redeemable_benefit_allotment.should == 2
          end
        end
      end

      context "with enough daily redeemable benefits" do
        let(:card) { create :card, redeemable_benefit_allotment: 3 }

        before do
          3.times do
            card.redeemable_benefits.create
          end
        end

        it "should use only daily redeemable benefits" do
          card.redeem_benefits! 2
          card.redeemable_benefit_allotment.should == 1
          card.redeemable_benefits.count.should == 3
          card.total_redeemable_benefit_allotment.should == 4
        end
      end
    end
  end
end
