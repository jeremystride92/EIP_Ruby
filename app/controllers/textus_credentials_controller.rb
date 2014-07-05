class TextusCredentialsController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue

  def edit
    @textus_credential = TextusCredential.find_or_initialize_by_venue_id(current_user.venue_id)

    authorize! :update, @textus_credential
  end

  def update
    @textus_credential = @venue.textus_credential || @venue.build_textus_credential
    @textus_credential.attributes = params_for_textus_credential

    authorize! :update, @textus_credential

    if @textus_credential.save
      redirect_to venue_path  , notice: "Textus.biz credentials configured."
    else
      render :edit
    end
  end

  def destroy
    @textus_credential = @venue.textus_credential

    if @textus_credential
      authorize! :manage, @textus_credential
      @textus_credential.destroy
    end

    redirect_to venue_path, notice: "Textus.biz credentials deleted. User data will not be saved to Textus.biz."
  end

  private

  def find_venue
    @venue = Venue.includes(:textus_credential).find current_user.venue_id
  end

  def params_for_textus_credential
    params.require(:textus_credential).permit(:username, :api_key)
  end
end
