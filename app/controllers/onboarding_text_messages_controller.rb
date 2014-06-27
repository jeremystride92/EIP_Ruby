class OnboardingTextMessagesController < ApplicationController
  before_filter :authenticate
  before_filter :find_venue

  def edit
    @onboarding_text_message = OnboardingTextMessage.find_or_initialize_by_venue_id(current_user.venue_id)

    authorize! :update, @onboarding_text_message
  end

  def update
    @onboarding_text_message = @venue.onboarding_text_message || @venue.build_onboarding_text_message
    @onboarding_text_message.attributes = params_for_onboarding_text_message

    authorize! :update, @onboarding_text_message

    if @onboarding_text_message.save
      redirect_to venue_path, notice: "Custom onboarding text message set."
    else
      render :edit
    end
  end

  def destroy
    @onboarding_text_message = @venue.onboarding_text_message

    if @onboarding_text_message
      authorize! :manage, @onboarding_text_message
      @onboarding_text_message.destroy
    end

    redirect_to venue_path, notice: "Custom onboarding text message deleted. Users will now see the default onboarding text message."
  end

  private

  def find_venue
    @venue = Venue.includes(:onboarding_text_message).find current_user.venue_id
  end

  def params_for_onboarding_text_message
    params.require(:onboarding_text_message).permit(:custom_text)
  end
end
