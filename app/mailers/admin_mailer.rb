class AdminMailer < ActionMailer::Base
  default from: ENV['site_email']

  def new_venue_email(venue)
    @venue = venue

    mail to: ENV['site_email'], subject: 'New venue created'
  end
end
