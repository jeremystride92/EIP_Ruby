require 'spec_helper'

describe Partner do
  it { should belong_to :venue }
  it { should have_many :temporary_cards }

  it { should validate_presence_of :name }

  it { should validate_numericality_of(:phone_number).only_integer }
  it { should allow_value(nil).for(:phone_number) }
  it { should ensure_length_of(:phone_number).is_equal_to(10) }
end
