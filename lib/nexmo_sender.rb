class NexmoSender
  def initialize(from: ENV['nexmo_default_sender'], to: '', message: '')
    @to = to
    @from = from
    @message = message
  end

  def deliver_mail(mail)
    $nexmo.send_message! to: @to, from: @from, text: @message
    log_message = [
      "[NEXMO DELIVERY]",
      "  From: #{@from}",
      "  To: #{@to}",
      "  Text: #{@message}"
    ].join("\n")
    Rails.logger.info log_message
  end
end
