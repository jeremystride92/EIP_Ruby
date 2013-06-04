require 'spec_helper'

describe Cardholder do
  it { should validate_presence_of :first_name }
  it { should validate_presence_of :last_name }
  it { should validate_presence_of :phone_number }
  it { should validate_uniqueness_of :phone_number }
end
