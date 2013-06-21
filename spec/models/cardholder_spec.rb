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
      it "should generate a valid random password if one isn't given" do
        cardholder = build :cardholder, password: nil, password_confirmation: nil
        cardholder.should be_valid
        cardholder.password.should_not be_nil
        other_cardholder = build :cardholder, password: nil, password_confirmation: nil
        other_cardholder.valid? # run validation in order to trigger callbacks
        cardholder.password.should_not == other_cardholder.password
      end

      it "should not generate password if one given" do
        cardholder = build :cardholder, password: 'short', password_confirmation: 'short'
        cardholder.valid? # run validation in order to trigger callbacks
        cardholder.password.should == 'short'
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

  describe "#generate_unusable_password!" do
    subject { build :cardholder, password: nil, password_confirmation: nil }

    before {subject.generate_unusable_password!}

    it "should set password" do
      subject.password.should_not be_nil
    end

    it "should set password_confirmation to match password" do
      subject.password_confirmation.should == subject.password
    end

    it "should generate a long password" do
      subject.password.length.should be >= 16
    end

    it "should generate a different password each time" do
      5.times{ expect{subject.generate_unusable_password!}.to change(subject, :password) }
    end
  end
end
