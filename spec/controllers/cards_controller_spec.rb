require 'spec_helper'

describe CardsController do
  let(:venue) { create :venue }
  let(:user) { create :user, password: 'password', password_confirmation: 'password', venue_id: venue.id }
  let(:card_level) { create :card_level, venue: venue }
  let(:cardholder) { create :cardholder }
  let(:card) { create :card, cardholder: cardholder, card_level: card_level}

  describe  "PUT review_card_request", sidekiq: :inline do
    before do
      login user
    end

    describe "for card with pending cardholder" do
      before do
        cardholder.update_attributes status: :pending
      end

      it "should send an onboarding email" do
        SmsMailer.any_instance.should_receive(:cardholder_onboarding_sms).with(cardholder.id, venue.id)
        SmsMailer.any_instance.should_not_receive(:cardholder_new_card_sms)

        put :review_card_request, card_id: card.id, approve: true, card: card.as_json
      end
    end

    describe "for card with active cardholder" do
      before do
        cardholder.update_attributes status: :active
      end

      it "should send a new card email" do
        SmsMailer.any_instance.should_not_receive(:cardholder_onboarding_sms)
        SmsMailer.any_instance.should_receive(:cardholder_new_card_sms).with(cardholder.id, venue.id)

        put :review_card_request, card_id: card.id, approve: true, card: card.as_json
      end
    end
  end
end