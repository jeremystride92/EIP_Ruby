class PromotionsController < ApplicationController
  before_filter :find_venue
  before_filter :find_promotions

  def new
    @promotion = @venue.promotions.build
    authorize! :create, @promotion
  end

  def create
    @promotion = @venue.promotions.build(params_for_promotion)
    authorize! :create, @promotion

    if @promotion.save
      redirect_to venue_promotion_path(@promotion)
    else
      render 'new'
    end
  end

  def show
    authorize! :read, @promotion
  end

  def edit
    authorize! :update, @promotion
  end

  def update
    authorize! :update, @promotion

    if @promotion.update_attributes(params_for_promotion)
      redirect_to venue_promotion_path(@promotion)
    else
      render 'edit'
    end
  end

  def destroy
    authorize! :destroy, @promotion
    @promotion.destroy
    head :no_content
  end

  private
  def params_for_promotion
    params.require(:promotion).permit(:title, :description, :start_date_field, :start_time_field, :end_date_field, :end_time_field, :image, :image_cache)
  end
  def find_venue
    @venue = current_user.venue
  end
  def find_promotions
    @promotion = Promotion.find(params[:id]) if params[:id]
  end
end
