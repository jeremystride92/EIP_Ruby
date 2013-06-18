require 'spec_helper'

describe Cardholder do
  context 'validations on create' do
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

  context 'validations on update' do
    subject { create :cardholder, first_name: nil, last_name: nil }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }

    it { should_not be_valid }
  end

  it { should have_many :cards }
end
