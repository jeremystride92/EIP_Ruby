require 'spec_helper'

describe Benefit do
  it { should validate_presence_of :description }
  it { should validate_presence_of :beneficiary }

  it { should be_an Expirable }
end
