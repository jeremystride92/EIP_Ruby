require 'spec_helper'

describe Promotion do
  it { should belong_to :venue  }
  it { should have_and_belong_to_many :card_levels }

  it { should validate_presence_of :title }
  it { should validate_presence_of :venue }

  it { should be_an Expirable }

  it { should be_a Comparable }

  describe "comparisons" do
    let(:dates) { [ 2.days.ago, 1.day.ago, 1.day.from_now, 2.days.from_now ] }

    # both nil
    let(:promo_1) { build :promotion, start_date: nil, end_date: nil }

    # end nil, different start dates
    let(:promo_2) { build :promotion, start_date: dates[2], end_date: nil }
    let(:promo_3) { build :promotion, start_date: dates[1], end_date: nil }

    # both non-nil
    let(:promo_4) { build :promotion, start_date: dates[1], end_date: dates[3] }
    let(:promo_5) { build :promotion, start_date: dates[1], end_date: dates[2] }
    let(:promo_6) { build :promotion, start_date: dates[0], end_date: dates[2] }

    # start nil, different end dates
    let(:promo_7) { build :promotion, start_date: nil, end_date: dates[3] }
    let(:promo_8) { build :promotion, start_date: nil, end_date: dates[2] }

    it 'should sort nil end_dates later than non-nil' do
      promo_2.should be_> promo_4
      promo_4.should be_< promo_2
    end

    it 'should sort by start_date when both end_dates are nil' do
      promo_2.should be_> promo_3
      promo_3.should be_< promo_2
    end

    it 'should sort by end_dates when both start_dates are nil' do
      promo_7.should be_> promo_8
      promo_8.should be_< promo_7
    end

    it 'should sort by end_dates when both end_dates are non-nil and different' do
      promo_4.should be_> promo_5
      promo_5.should be_< promo_4
    end

    it 'should sort by start_dates when both end_dates are non-nil and equal' do
      promo_5.should be_> promo_6
      promo_6.should be_< promo_5
    end

    it 'should put infinite promotions after terminating ones, but before starting ones' do
      promo_1.should be_> promo_8
      promo_8.should be_< promo_1

      promo_2.should be_> promo_1
      promo_1.should be_< promo_2
    end

  end
end
