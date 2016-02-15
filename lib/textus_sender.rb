require 'base64'

class TextusSender

  def initialize(credentials: nil, receiver: '', message: '')
    @credentials = credentials
    @receiver = "+#{receiver}" # TextUs requires a plus before the number
    @message = message
  end
    
  def deliver_mail(mail)
    log_message = [
      "[TEXTUS DELIVERY]",
      "  Sender: #{@credentials.username}",
      "  Receiver: #{@receiver}",
      "  Message: #{@message}"
    ].join("\n")
    Rails.logger.info log_message

    HTTParty.post("https://app.textus.com:443/api/messages", body: {
      content: @message,
      sender: @credentials.username,
      receiver: @receiver
    }.to_json,
    headers: {"Content-Type" => "application/json", "Authorization" => Base64.encode64("#{@credentials.username}:#{@credentials.api_key}"), "Accept" => "application/vnd.textus-v2"},
    basic_auth: {
      username: @credentials.username,
      password: @credentials.api_key
    })

  end
end
