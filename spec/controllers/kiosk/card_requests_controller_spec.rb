require 'spec_helper'

describe Kiosk::CardRequestsController do

  let(:card_level) { create :card_level }
  let(:venue) { card_level.venue }

  before do
    @request.host = "#{venue.vanity_slug}.example.com"
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end

    it 'assigns @cardholder' do
      get 'new'
      assigns(:cardholder).should_not be_nil
      assigns(:cardholder).should_not be_persisted
    end
  end

  describe "POST 'create'" do
    it "returns http redirect" do
      post 'create', cardholder: { phone_number: '1234567890', first_name: 'Bob', last_name: 'Smith' }
      response.should be_redirect
    end
  end

end
