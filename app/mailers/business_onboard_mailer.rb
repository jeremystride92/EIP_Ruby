class BusinessOnboardMailer < ActionMailer::Base
  default from: ENV['site_email']

  def onboard_email(user_id)
    @user = User.find(user_id)
    @venue = @user.venue
    mail to: @user.email, subject: "#{@venue.name} Admin Access"
  end
end
