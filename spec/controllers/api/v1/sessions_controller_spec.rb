require 'spec_helper'

describe Api::V1::SessionsController do
  describe "create" do
    it "should return an auth token when given valid credentials" do
      cardholder = create :cardholder, password: 'wombat'
      post :create, { phone_number:cardholder.phone_number, password:'wombat' }
      response.body.should =~ /#{cardholder.auth_token}/
    end

    it "should be unauthorized with bad credentials" do
      cardholder = create :cardholder, password: 'wombat'
      post :create, { phone_number:cardholder.phone_number, password:'kangaroo' }
      response.status.should == 401
      response.body.should_not =~ /#{cardholder.auth_token}/
    end
  end
end
