class PartnersController < ApplicationController
  before_filter :find_venue
  before_filter :find_partner, only: [:edit, :update, :destroy]

  def index
    authorize! :read, Partner
    @partners = @venue.partners.sort_by &:name
  end

  def new
    @partner = @venue.partners.build
    authorize! :create, @partner
  end

  def create
    @partner = Partner.new params_for_partner
    @partner.venue = @venue
    @partner.default_benefits = params_for_default_benefits.values.map(&:values).flatten.map(&:values).flatten

    authorize! :create, @partner

    if @partner.save
      redirect_to venue_partners_path, notice: "Partner added."
    else
      render :new
    end
  end

  def edit
    authorize! :update, @partner
  end

  def update
    authorize! :update, @partner

    @partner.assign_attributes params_for_partner
    @partner.default_benefits = params_for_default_benefits.values.map(&:values).flatten.map(&:values).flatten

    if @partner.save
      redirect_to venue_partners_path, notice: "Partner updated."
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @partner
    @partner.destroy
    redirect_to venue_partners_path, notice: "Partner deleted."
  end

  private

  def find_venue
    @venue = Venue.includes(:card_themes, partners: [:temporary_cards]).find current_user.venue_id
  end

  def find_partner
    @partner = @venue.partners.find params[:id]
  end

  def params_for_partner
    params.require(:partner).permit(:name, :phone_number, :default_guest_count, :card_theme_id)
  end

  def params_for_default_benefits
    params.permit(batch: { benefits_attributes: [:description] }).fetch(:batch, {})
  end
end
