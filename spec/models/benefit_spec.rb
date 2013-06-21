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
end
