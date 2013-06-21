require 'spec_helper'

describe Cardholder do
  describe "Validations" do
    context 'on create' do
      subject { build :cardholder, first_name: nil, last_name: nil }
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

      it { should be_valid }
    end

    context 'on update' do
      subject { create :cardholder, first_name: nil, last_name: nil }
      it { should validate_presence_of :first_name }
      it { should validate_presence_of :last_name }

      it { should_not be_valid }
    end

    context "on a new cardholder" do
      it "should not be valid without a password" do
        cardholder = build :cardholder, password: nil, password_confirmation: nil
        cardholder.should_not be_valid
      end

      it "should be not be valid with a short password" do
        cardholder = build :cardholder, password: 'short', password_confirmation: 'short'
        cardholder.should_not be_valid
      end

      it "should not be valid with a confirmation mismatch" do
        cardholder = build :cardholder, password: 'short', password_confirmation: 'long'
        cardholder.should_not be_valid
      end
    end

    context "on an existing cardholder" do
      let(:cardholder) { create :cardholder }

      it "should be valid with no changes" do
        cardholder.should be_valid
      end

      it "should not be valid with an empty password" do
        cardholder.password = cardholder.password_confirmation = ""
        cardholder.should_not be_valid
      end

      it "should be valid with a new (valid) password" do
        cardholder.password = cardholder.password_confirmation = "new password"
        cardholder.should be_valid
      end
    end
  end

  it { should have_many :cards }

  describe "authentication" do
    it "should generate auth_token on create" do
      cardholder = build :cardholder
      cardholder.auth_token.should be_nil
      cardholder.save
      cardholder.auth_token.should_not be_nil
    end

    it "should authenticate with correct password" do
      cardholder = create :cardholder
      cardholder.authenticate(cardholder.password).should_not == false
    end

    it "should not authenticate with incorrect password" do
      cardholder = create :cardholder
      cardholder.authenticate('incorrect').should == false
    end
  end
end
