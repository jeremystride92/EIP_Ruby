require 'spec_helper'

describe Api::V1::SessionsController do
  describe "create" do
    it "should return an auth token when given valid credentials" do
      cardholder = create :cardholder, password: '1234'
      post :create, { phone_number: cardholder.phone_number, password: '1234' }
      response.body.should =~ /#{cardholder.auth_token}/
    end

    context "when the cardholder is pending" do
      it "returns the onboarding information" do
        cardholder = create :pending_cardholder
        post :create, { phone_number: cardholder.phone_number }
        body = JSON.parse(response.body)
        body["first_name"].should == cardholder.first_name
        body["last_name"].should == cardholder.last_name
        body["onboarding_token"].should == cardholder.onboarding_token
        body["onboarding"].should be_present
        body["auth_token"].should be_blank
      end
    end

    context "when pin is not required" do
      before do
        ENV['require_pin'] = 'not required'
      end

      it "should be authorized without credentials" do
        cardholder = create :cardholder, password: '1234'
        post :create, { phone_number: cardholder.phone_number }
        response.status.should == 200
        response.body.should =~ /#{cardholder.auth_token}/
      end

    end

    context "When pin is required" do
      before do
        ENV['require_pin'] = 'required'
      end

      it "should be unauthorized with bad credentials" do
        cardholder = create :cardholder, password: '1234'
        post :create, { phone_number: cardholder.phone_number, password: '5678' }
        response.status.should == 401
        response.body.should_not =~ /#{cardholder.auth_token}/
      end

    end
  end
end
