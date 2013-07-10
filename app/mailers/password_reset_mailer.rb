class PasswordResetMailer < ActionMailer::Base
  default from: ENV['site_email']

  def password_reset_email(user)
    @user = user
    @venue = user.venue
    mail to: user.email, subject: "Change your EIPiD password"
  end
end
