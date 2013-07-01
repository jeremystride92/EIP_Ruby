require 'spec_helper'

describe Promotion do
  describe "associations" do
    it { should belong_to :venue  }
  end

  describe "validations" do
    it { should validate_presence_of :title }
    it { should validate_presence_of :venue }
  end

  describe 'factory' do
    subject { create :promotion }

    it { should be_valid }
  end
end
