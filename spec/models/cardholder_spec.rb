require 'spec_helper'

describe Cardholder do
  context 'validations on create' do
    subject { build :cardholder, first_name: nil, last_name: nil }
    it { should validate_presence_of :phone_number }
    it { should validate_uniqueness_of :phone_number }

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
