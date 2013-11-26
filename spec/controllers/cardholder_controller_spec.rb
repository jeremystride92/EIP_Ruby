require 'spec_helper'

describe CardholdersController do
  let(:venue1) { create :venue }
  let(:venue2) { create :venue }
  let(:user) { create :user, password: 'password', password_confirmation: 'password', venue: venue1 }
  let(:card_level1) { create :card_level, venue: venue1 }
  let(:card_level2) { create :card_level, venue: venue2 }

  describe "POST bulk_resend_onboarding_sms" do
    before do
      login user
    end

    describe "should send onboarding sms messages to pending cardholders", sidekiq: :inline do
      let(:cardholders) { create_list :cardholder, 3, status: :pending}
      

      it "to pending cardholders" do
        

        cardholders.each do |cardholder|
          card = create :card, cardholder: cardholder, card_level: card_level1
        end

        run_count = 0
        SmsMailer.any_instance.stub(:cardholder_onboarding_sms) do |a,b|
          run_count += 1
          cardholders.map(&:id).include?(a).should == true
          b.should == venue1.id
        end

        post :bulk_resend_onboarding_sms
        run_count.should == cardholders.count

      end

      it "to pending cardholders with active cards" do 
        cardholders.each do |cardholder|
          card = create :card, cardholder: cardholder, card_level: card_level1, status: 'active'
        end

        run_count = 0
        SmsMailer.any_instance.stub(:cardholder_onboarding_sms) do |a,b|
          run_count += 1
          cardholders.map(&:id).include?(a).should == true
          b.should == venue1.id
        end

        post :bulk_resend_onboarding_sms
        run_count.should == cardholders.count

      end


    end

    describe "should not send onboarding sms messages" do

      it "to active cardholders" do
        cardholders = create_list :cardholder, 3, status: :active
        cardholders.each do |cardholder|
          card = create :card, cardholder: cardholder, card_level: card_level1, status: 'active'
        end

        SmsMailer.any_instance.should_not_receive(:cardholder_onboarding_sms)

        post :bulk_resend_onboarding_sms

      end

      it "to cardholders from other venues" do
        cardholders = create_list :cardholder, 3, status: :pending
        
        cardholders.each do |cardholder|
          card = create :card, cardholder: cardholder, card_level: card_level2, status: 'active'
        end

        SmsMailer.any_instance.should_not_receive(:cardholder_onboarding_sms)

        post :bulk_resend_onboarding_sms
      end
    end

    
  end

end