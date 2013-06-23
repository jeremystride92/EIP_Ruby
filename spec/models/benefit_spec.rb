require 'spec_helper'

describe Benefit do
  it { should validate_presence_of :description }
  it { should validate_presence_of :beneficiary }

  describe "datetime fields" do
    describe "#start_date" do
      it "should merge date and time fields into datetime field" do
        b = create :benefit, start_date: nil, start_date_field: '2011-04-01', start_time_field: '11:22 PM'
        b.start_date.should_not be_nil
        b.start_date.to_s(:db).should == '2011-04-01 23:22:00'
      end

      it "should clear datetime field if empty start_date_field" do
        time = Time.now
        b = create :benefit, start_date: time, start_date_field: '', start_time_field: '11:22 PM'
        b.start_date.should be_nil
      end
    end

    describe "#end_date" do
      it "should merge date and time fields into datetime field" do
        b = create :benefit, end_date: nil, end_date_field: '2011-04-01', end_time_field: '11:22 PM'
        # binding.pry
        b.end_date.should_not be_nil
        b.end_date.to_s(:db).should == '2011-04-01 23:22:00'
      end

      it "should clear datetime field if empty end_date_field" do
        time = Time.now
        b = create :benefit, end_date: time, end_date_field: '', end_time_field: '11:22 PM'
        b.end_date.should be_nil
      end
    end
  end

  describe "#inactive? and #active?" do
    context "with no end date, and started yesterday" do
      let(:benefit) { build :benefit, start_date: 1.day.ago }

      it "should be inactive two days ago" do
        benefit.should be_inactive 2.days.ago
      end

      it "should be active two days ago" do
        benefit.should_not be_active 2.days.ago
      end

      it "should not be inactive today" do
        benefit.should_not be_inactive
      end

      it "should be active today" do
        benefit.should be_active
      end
    end

    context "with no start date, and ended yesterday" do
      let(:benefit) { build :benefit, end_date: 1.day.ago }

      it "should not be inactive two days ago" do
        benefit.should_not be_inactive 2.days.ago
      end

      it "should be active two days ago" do
        benefit.should be_active 2.days.ago
      end

      it "should be inactive today" do
        benefit.should be_inactive
      end

      it "should not be active today" do
        benefit.should_not be_active
      end
    end
  end
end
