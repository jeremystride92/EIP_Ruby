require 'spec_helper'

describe CardLevel do
  it { should validate_presence_of :name }
  it { should belong_to :venue }
  it { should have_many :cards }
  it { should validate_uniqueness_of(:name).scoped_to(:venue_id) }

  it 'serializes benefits' do
    cl = create :card_level
    cl.benefits << 'Extra Benefit'
    cl.save

    found_cl = CardLevel.find cl.id
    found_cl.benefits.should have(3).strings
    found_cl.benefits.last.should == 'Extra Benefit'
  end
end
