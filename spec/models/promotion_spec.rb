require 'spec_helper'

describe Promotion do
  it { should belong_to :venue  }
  it { should have_and_belong_to_many :card_levels }

  it { should validate_presence_of :title }
  it { should validate_presence_of :venue }

  it { should be_an Expirable }

  describe 'factory' do
    subject { create :promotion }

    it { should be_valid }
  end
end
