require 'spec_helper'

describe TemporaryCard do
  it { should belong_to :partner }
  it { should belong_to :issuer }
  it { should have_one(:venue).through(:partner) }

  it { should validate_presence_of :expires_at }

  it { should validate_numericality_of(:phone_number).only_integer }
  it { should allow_value(nil).for(:phone_number) }
  it { should ensure_length_of(:phone_number).is_equal_to(10) }

  describe "newly created record" do
    subject { create :temporary_card }

    its(:access_token) { should_not be_nil }
  end

  describe "#expired? and #active?" do
    context "on an expired record" do
      subject { create :temporary_card, expires_at: 1.day.ago }

      it { should be_expired }
      it { should_not be_active }

      it { should_not be_expired 2.days.ago }
      it { should be_active 2.days.ago }
    end

    context "on an active record" do
      subject { create :temporary_card, expires_at: 1.day.from_now }

      it { should_not be_expired }
      it { should be_active }

      it { should be_expired 2.days.from_now }
      it { should_not be_active 2.days.from_now }
    end
  end
end
