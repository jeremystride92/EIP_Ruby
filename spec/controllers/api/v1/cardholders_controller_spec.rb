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
end
