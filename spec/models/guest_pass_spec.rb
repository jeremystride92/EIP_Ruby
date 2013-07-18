require 'spec_helper'

describe GuestPass do
  it { should belong_to :card }

  it { should validate_presence_of :card }

  it { should be_an Expirable }
end
