class NexmoSender
  def client
    # reconnect for every to prevent stale SSL issues.
    Nexmo::Client.new(ENV['nexmo_key'], ENV['nexmo_secret'])
  end

  def initialize(from: ENV['nexmo_default_sender'], to: '', message: '')
    @to = to
    @from = from
    @message = message
  end

  def deliver_mail(mail)
    log_message = [
      "[NEXMO DELIVERY]",
      "  From: #{@from}",
      "  To: #{@to}",
      "  Text: #{@message}"
    ].join("\n")
    Rails.logger.info log_message

    client.send_message! to: @to, from: @from, text: @message
  end
end
