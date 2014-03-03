require 'spec_helper'

describe Api::V1::CardholdersController do
  it "should return unauthorized if invalid auth token" do
    get 'show', nil, authorization: 'bad_token'
    response.status.should == 401
  end

  it "should set @cardholder if valid auth token" do
    cardholder = create :cardholder
    use_http_auth_token_for(cardholder)
    get 'show'
    response.status.should == 200
    assigns(:cardholder).should == cardholder
  end

  describe "#complete_onboard" do
    it "onboards a cardholder" do
      cardholder = create :pending_cardholder

      params = {
          cardholder: {
              first_name: "Bob",
              last_name: "Smith",
              photo: "photo.jpg",
              photo_cache: "photo_cache.jpg",
              onboarding_token: cardholder.onboarding_token
          },
          format: "json"
      }

      post 'complete_onboard', params

      response.should be_success
      cardholder.reload
      cardholder.first_name.should == "Bob"
      cardholder.last_name.should == "Smith"
      cardholder.should be_active
      cardholder.should
      JSON.parse(response.body).should == { "success" => "Cardholder updated" }
    end
  end
end
