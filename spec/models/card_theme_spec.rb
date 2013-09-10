require 'spec_helper'

describe CardTheme do
  it { should belong_to :venue }

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).scoped_to(:venue_id) }
end
