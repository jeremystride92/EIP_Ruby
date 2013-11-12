class PasswordResetMailer < ActionMailer::Base
  default from: ENV['site_email']

  def password_reset_email(user_id)
    @user = User.find(user_id)
    @venue = @user.venue
    mail to: @user.email, subject: "Change your EIPiD password"
  end
end
