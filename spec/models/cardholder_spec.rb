require 'spec_helper'

describe Cardholder do
  context 'validations on create' do
    subject { build :cardholder, first_name: nil, last_name: nil }
    it { should validate_presence_of :phone_number }
    it { should validate_uniqueness_of :phone_number }

    it { should be_valid }

    it 'should be invalid with dashes in the phone number' do
      subject.phone_number = '123-456-7890'
      subject.should_not be_valid
    end

    it 'should be invalid with other characters in the phone number' do
      subject.phone_number = 'one two 3'
      subject.should_not be_valid
    end
  end

  context 'validations on update' do
    subject { create :cardholder, first_name: nil, last_name: nil }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }

    it { should_not be_valid }
  end

  it { should have_many :cards }
end
