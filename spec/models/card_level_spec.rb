require 'spec_helper'

describe CardLevel do
  it { should validate_presence_of :name }
  it { should belong_to :venue }
  it { should have_many :cards }
  it { should validate_uniqueness_of(:name).scoped_to(:venue_id) }
end
