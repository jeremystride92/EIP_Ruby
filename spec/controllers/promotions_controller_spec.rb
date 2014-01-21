require 'spec_helper'

describe PromotionsController do
  describe "PUT update" do

    let(:user) { create :user }

    it "should redirect back to list all promotions" do
      login user
      venue = create :venue, users: [user]
      promotion = create :promotion, venue: venue

      put :update, id: promotion.id, venue_id: promotion.venue.id, promotion: promotion.as_json.symbolize_keys!.slice(:title, :description)
      response.should redirect_to venue_promotions_path
    end
  end
end