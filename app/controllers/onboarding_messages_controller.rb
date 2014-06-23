class OnboardingMessagesController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue

  def edit
    @onboarding_message = OnboardingMessage.find_or_initialize_by_venue_id(current_user.venue_id)

    authorize! :update, @onboarding_message
  end

  def update
    @onboarding_message = @venue.onboarding_message || @venue.build_onboarding_message
    @onboarding_message.attributes = params_for_onboarding_message

    authorize! :update, @onboarding_message

    if @onboarding_message.save
      redirect_to venue_path  , notice: "Custom onboarding message set."
    else
      render :edit
    end
  end

  def destroy
    @onboarding_message = @venue.onboarding_message

    if @onboarding_message
      authorize! :manage, @onboarding_message
      @onboarding_message.destroy
    end

    redirect_to venue_path, notice: "Custom onboarding message deleted. Users will now see the default onboarding message."
  end

  private

  def find_venue
    @venue = Venue.includes(:onboarding_message).find current_user.venue_id
  end

  def params_for_onboarding_message
    params.require(:onboarding_message).permit(:custom_text)
  end
end
