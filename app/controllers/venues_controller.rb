class VenuesController < ApplicationController
  def new
    @venue = Venue.new
  end

  def create
    @venue = Venue.new venue_params.merge(owner: current_user)

    if @venue.save
      redirect_to @venue, notice: 'Venue created!'
    else
      render :new
    end
  end

  def show
    @venue = Venue.find(params[:id])
  end

  private
  def venue_params
    params.require(:venue).permit(:name, :phone, :location, :address1, :address2, :website, :vanity_slug)
  end
end
