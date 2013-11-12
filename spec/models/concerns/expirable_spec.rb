require 'spec_helper'

class Dummy
  attr_accessor :start_date, :end_date

  def self.before_validation(symbol)
  end

  include Expirable

  def initialize(start_date: nil, end_date: nil)
    self.start_date = start_date
    self.end_date = end_date
  end

  def start_date_changed?
    @start_date_will_change
  end

  def start_date_will_change!
    @start_date_will_change = true
  end

  def end_date_changed?
    @end_date_will_change
  end

  def end_date_will_change!
    @end_date_will_change = true
  end

  def save
    self.merge_datetime_fields
    self.start_date = Time.zone.parse(self.start_date) if self.start_date
    self.end_date = Time.zone.parse(self.end_date) if self.end_date
  end
end

describe Expirable do
  describe "datetime fields" do
    describe "#start_date" do
      it "should merge date and time fields into datetime field" do
        d = Dummy.new start_date: nil
        d.start_date_field = '2011-04-01'
        d.start_time_field = '11:22 PM'
        d.save

        d.start_date.should_not be_nil
        d.start_date.to_s(:db).should == '2011-04-01 23:22:00'
      end

      it "should clear datetime field if empty start_date_field" do
        time = Time.zone.now
        d = Dummy.new start_date: time
        d.start_date_field = ''
        d.start_time_field = '11:22 PM'
        d.save

        d.start_date.should be_nil
      end
    end

    describe "#end_date" do
      it "should merge date and time fields into datetime field" do
        d = Dummy.new
        d.end_date_field = '2011-04-01'
        d.end_time_field = '11:22 PM'
        d.save

        d.end_date.should_not be_nil
        d.end_date.to_s(:db).should == '2011-04-01 23:22:00'
      end

      it "should set datetime to end of day if no time present" do
        d = Dummy.new
        d.end_date_field = '2011-04-01'
        d.end_time_field = ''
        d.save
        d.end_date.to_s(:db).should == '2011-04-01 23:59:59'
      end

      it "should clear datetime field if empty end_date_field" do
        time = Time.zone.now
        d = Dummy.new end_date: time
        d.end_date_field = ''
        d.end_time_field = '11:22 PM'
        d.save

        d.end_date.should be_nil
      end
    end
  end

  describe "#inactive? and #active?" do
    context "with no end date, and started yesterday" do
      subject { Dummy.new start_date: 1.day.ago }

      it { should be_inactive 2.days.ago }
      it { should_not be_active 2.days.ago}

      it { should_not be_inactive }
      it { should be_active }
    end

    context "with no start date, and ended yesterday" do
      subject { Dummy.new end_date: 1.day.ago }

      it { should_not be_inactive 2.days.ago }
      it { should be_active 2.days.ago }

      it { should be_inactive }
      it { should_not be_active }
    end
  end

  describe "#active_in_range?" do
    let(:start_date) { 2.days.ago }
    let(:end_date) { 2.days.from_now }

    context "when it starts too late" do
      subject { Dummy.new start_date: 3.days.from_now }

      it { should_not be_active_in_range start_date, end_date }
    end

    context "when it starts soon enough" do
      subject { Dummy.new start_date: 4.days.ago }

      context "when it ends too soon" do
        before { subject.end_date = 3.days.ago }

        it { should_not be_active_in_range start_date, end_date }
      end

      context "when it ends late enough" do
        before { subject.end_date = 1.day.ago }

        it { should be_active_in_range start_date, end_date }
      end
    end
  end

  describe "#permanent?" do
    it "should be true with no start/end date" do
      Dummy.new.should be_permanent
    end

    it "should be false with a start date" do
      Dummy.new(start_date: Date.today).should_not be_permanent
    end

    it "should be false with an end date" do
      Dummy.new(end_date: Date.today).should_not be_permanent
    end
  end

  describe "#temporary?" do
    it "should be false with no start/end date" do
      Dummy.new.should_not be_temporary
    end

    it "should be true with a start date" do
      Dummy.new(start_date: Date.today).should be_temporary
    end

    it "should be true with an end date" do
      Dummy.new(end_date: Date.today).should be_temporary
    end
  end

  describe "#expired?" do
    let (:start_date) { 2.days.ago }
    let (:end_date) { 2.days.from_now }

    subject { Dummy.new start_date: start_date }

    context "when no end is specified" do
      it { should_not be_expired }
    end

    context "when an end is specified in the future" do
      before { subject.end_date = end_date }

      it { should_not be_expired }
    end

    context "when it is explicitly expired" do
      before { subject.expire }

      it { should be_expired } 
    end

  end
end
