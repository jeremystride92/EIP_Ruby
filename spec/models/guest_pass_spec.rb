require 'spec_helper'

describe GuestPass do
  it { should belong_to :card }

  it { should validate_presence_of :card }

  describe "datetime fields" do
    describe "#start_date" do
      it "should merge date and time fields into datetime field" do
        b = create :guest_pass, start_date: nil, start_date_field: '2011-04-01', start_time_field: '11:22 PM'
        b.start_date.should_not be_nil
        b.start_date.to_s(:db).should == '2011-04-01 23:22:00'
      end

      it "should clear datetime field if empty start_date_field" do
        time = Time.now
        b = create :guest_pass, start_date: time, start_date_field: '', start_time_field: '11:22 PM'
        b.start_date.should be_nil
      end
    end

    describe "#end_date" do
      it "should merge date and time fields into datetime field" do
        b = create :guest_pass, end_date: nil, end_date_field: '2011-04-01', end_time_field: '11:22 PM'
        b.end_date.should_not be_nil
        b.end_date.to_s(:db).should == '2011-04-01 23:22:00'
      end

      it "should clear datetime field if empty end_date_field" do
        time = Time.now
        b = create :guest_pass, end_date: time, end_date_field: '', end_time_field: '11:22 PM'
        b.end_date.should be_nil
      end
    end
  end

  describe "#inactive? and #active?" do
    context "with no end date, and started yesterday" do
      subject { build :guest_pass, start_date: 1.day.ago }

      it { should be_inactive 2.days.ago }
      it { should_not be_active 2.days.ago}

      it { should_not be_inactive }
      it { should be_active }
    end

    context "with no start date, and ended yesterday" do
      subject { build :guest_pass, end_date: 1.day.ago }

      it { should_not be_inactive 2.days.ago }
      it { should be_active 2.days.ago }

      it { should be_inactive }
      it { should_not be_active }
    end
  end
end
