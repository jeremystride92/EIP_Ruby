require 'base64'
# PK Additions
require 'uri'
require 'net/http'

class TextusSender

  def initialize(credentials: nil, receiver: '', message: '')
    @credentials = credentials
    @receiver = "+#{receiver}" # TextUs requires a plus before the number
    @message = message
    @encCreds = Base64.encode64("#{@credentials.username}:#{@credentials.api_key}")
  end

  def deliver_mail(mail)

    # HTTParty.post("https://app.textus.com:443/api/messages",
    # body: {
    #   content: @message,
    #   sender: @credentials.username,
    #   receiver: @receiver
    # }.to_json,
    # headers: {
    #   "Content-Type" => "application/json",
    #   "Authorization" => Base64.encode64("#{@credentials.username}:#{@credentials.api_key}"),
    #   "Accept" => "application/vnd.textus-v2"},
    # basic_auth: {
    #   username: @credentials.username,
    #   password: @credentials.api_key
    # })
    #
    # PK (7/3/16): lol jk, no HTTParty. Doesn't work. Replacing with working code thats not very pretty in the initialize function because as far as I can tell from using the logs, this function isn't called.

    url = URI("https://app.textus.com:443/api/messages")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
    request["authorization"] = 'Basic '+@encCreds
    request["accept"] = 'application/vnd.textus-v2'
    request["cache-control"] = 'no-cache'
    #request["postman-token"] = 'fa34655e-d02f-a674-223c-ea4bc338ddfb'
    request.body = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"content\"\r\n\r\n"+@message+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"sender\"\r\n\r\n"+@credentials.username+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"receiver\"\r\n\r\n"+@receiver+"\r\n-----011000010111000001101001--"

    @response = http.request(request)

    log_message = [
      "[TEXTUS TextusSender deliver_mail called!]",
      # "  Sender: #{@credentials.username}",
      # "  Receiver: #{@receiver}",
      # "  Message: #{@message}",

      "  response.code: #{@response.code}",
      "  response.message: #{@response.message}",
      "  response.body: #{@response.body}",
    ].join("\n")
    Rails.logger.info log_message

    # abort('Sent the damn mail');
  end
end
