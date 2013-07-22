require 'spec_helper'

describe Cardholder do
  it { should have_many :cards }

  describe "Validations" do
    context 'always' do
      subject { build :cardholder }
      it { should validate_presence_of :phone_number }
      it { should validate_uniqueness_of :phone_number }
      it { should validate_numericality_of :phone_number }

      it 'validates length of phone_number' do
        subject.phone_number = '123456789'
        subject.should_not be_valid

        subject.phone_number = '1234567890'
        subject.should be_valid

        subject.phone_number = '12345678901'
        subject.should_not be_valid
      end

      it { should validate_numericality_of(:password).only_integer }
      it { should ensure_length_of(:password).is_equal_to(4) }
    end

    context 'when pending' do
      subject { build :pending_cardholder }

      it { should_not validate_presence_of :first_name }
      it { should_not validate_presence_of :last_name }
    end

    context 'when active' do
      subject { build :cardholder }

      it { should validate_presence_of :first_name }
      it { should validate_presence_of :last_name }
    end

    context "on a new cardholder" do
      it "should generate a valid random PIN if one isn't given" do
        cardholder = build :cardholder, password: nil, password_confirmation: nil
        cardholder.should_receive(:generate_unusable_password!).and_call_original
        cardholder.should be_valid
      end

      it "should not generate PIN if one given" do
        cardholder = build :cardholder, password: '1234', password_confirmation: '1234'
        cardholder.valid? # run validation in order to trigger callbacks
        cardholder.password.should == '1234'
      end

      it "should not be valid with a confirmation mismatch" do
        cardholder = build :cardholder, password: '1234', password_confirmation: '5678'
        cardholder.should_not be_valid
      end

      it "should be valid when created with nested card" do
        issuer = create :venue_manager
        card_level = create :card_level, venue: issuer.venue
        cards = attributes_for_list :card, 1, issuer_id: issuer.id, card_level_id: card_level.id
        cardholder_with_card = create :cardholder, cards_attributes: cards
        cardholder_with_card.should be_valid
      end
    end

    context "on an existing cardholder" do
      let(:cardholder) { create :cardholder }

      it "should be valid with no changes" do
        cardholder.should be_valid
      end

      it "should not be valid with an empty PIN" do
        cardholder.password = cardholder.password_confirmation = ""
        cardholder.should_not be_valid
      end

      it "should be valid with a new (valid) PIN" do
        cardholder.password = cardholder.password_confirmation = "5678"
        cardholder.should be_valid
      end
    end
  end

  describe "authentication" do
    it "should generate auth_token on create" do
      cardholder = build :cardholder
      cardholder.auth_token.should be_nil
      cardholder.save
      cardholder.auth_token.should_not be_nil
    end

    it "should authenticate with correct PIN" do
      cardholder = create :cardholder
      cardholder.authenticate(cardholder.password).should_not == false
    end

    it "should not authenticate with incorrect PIN" do
      cardholder = create :cardholder
      cardholder.authenticate('0000').should == false
    end
  end

  describe "#generate_unusable_password!" do
    subject { build :cardholder, password: nil, password_confirmation: nil }

    before {subject.generate_unusable_password!}

    it "should set password_digest" do
      subject.password_digest.should_not be_nil
    end
    it "should generate a long digest" do
      subject.password_digest.length.should be >= 16
    end

    it "should generate a different digest each time" do
      5.times{ expect{subject.generate_unusable_password!}.to change(subject, :password_digest) }
    end
  end

  describe "#active? and #pending?" do
    context "when pending" do
      subject { build :pending_cardholder }

      it { should_not be_active }
      it { should be_pending }
    end

    context "when active" do
      subject { build :cardholder }

      it { should be_active }
      it { should_not be_pending }
    end
  end

  describe "#activate!" do
    let(:cardholder) { create :pending_cardholder }

    it "does not work if names are not set" do
      cardholder.activate!.should be_false
      cardholder.reload.should be_pending
    end

    context "when both names are set" do
      before do
        cardholder.first_name = "First"
        cardholder.last_name = "Last"
      end

      it "succeeds" do
        cardholder.activate!.should be_true
      end

      it "sets the status to active" do
        cardholder.activate!
        cardholder.should be_active
      end
    end
  end

  describe "#has_card_for_venue?" do
    context "when card exists for given venue" do
      let(:venue) { create :venue }
      let(:card_level) { create :card_level, venue: venue }
      let(:cardholder) { create :cardholder }
      let!(:card) { create :card, card_level: card_level, cardholder: cardholder }

      it "should have card for venue" do
        cardholder.should have_card_for_venue venue
      end
    end

    context "when card does not exists for given venue" do
      let(:venue) { create :venue }
      let!(:card_level) { create :card_level, venue: venue }
      let(:cardholder) { create :cardholder }

      it "should have card for venue" do
        cardholder.should_not have_card_for_venue venue
      end
    end
  end

  describe "#international_phone_number" do
    let (:cardholder) { build :cardholder }
    subject { cardholder.international_phone_number }

    it { should == "1#{cardholder.phone_number}" }
  end
end
