require 'spec_helper'

describe RedeemableBenefit do
  it { should belong_to :card }

  it { should validate_presence_of :card }

  it { should be_an Expirable }

  describe '#redeem!' do
    let(:benefit) { create :redeemable_benefit, end_date: 10.days.from_now }
    let(:redemption_time) { Time.current }

    before do
      benefit.redeem!(redemption_time)
    end

    it 'should be redeemed_at redemption_time' do
      benefit.redeemed_at.to_i.should == redemption_time.to_i
    end

    it 'should not be active' do
      benefit.should_not be_active
    end

    it 'should be inactive' do
      benefit.should be_inactive
    end
  end

  describe '#redeemed?' do
    subject { build :redeemable_benefit, redeemed_at: nil }

    context 'when redeemed' do
      subject { build :redeemable_benefit, redeemed_at: 1.day.ago }

      it { should be_redeemed }
    end

    context 'when not redeemed' do
      subject { build :redeemable_benefit, redeemed_at: nil }

      it { should_not be_redeemed }
    end
  end

  describe '.redeemed' do
    let!(:redeemed_benefit) { create :redeemable_benefit, redeemed_at: 1.day.ago }
    let!(:unredeemed_benefit) { create :redeemable_benefit }

    subject { RedeemableBenefit.redeemed.all }

    it { should =~ [redeemed_benefit] }
  end
end
