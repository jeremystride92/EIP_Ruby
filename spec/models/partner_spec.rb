require 'spec_helper'

describe Partner do
  it { should belong_to :venue }
  it { should belong_to :card_theme }

  it { should have_many :temporary_cards }

  it { should validate_presence_of :name }

  it { should validate_numericality_of(:phone_number).only_integer }
  it { should allow_value(nil).for(:phone_number) }
  it { should ensure_length_of(:phone_number).is_equal_to(10) }

  it { should validate_presence_of :default_guest_count }
  it { should validate_numericality_of(:default_guest_count).only_integer.is_greater_than_or_equal_to(0) }

  describe "#default_benefits" do
    it "should set to [] if not set" do
      partner = create :partner, default_benefits: nil
      partner.default_benefits.should == []
    end
  end

  describe "#active_cards_count and #lifetime_cards_count" do
    subject { create :partner }

    let!(:expired_card) { create :temporary_card, partner: subject, expires_at: 1.day.ago }
    let!(:active_card) { create :temporary_card, partner: subject, expires_at: 1.day.from_now }

    its(:active_cards_count) { should == 1 }
    its(:lifetime_cards_count) { should == 2 }
  end
end
