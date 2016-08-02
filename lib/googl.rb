class Googl
  def self.shorten_url(url)
    begin
      resp = HTTParty.post("https://www.googleapis.com/urlshortener/v1/url?key=#{ENV['googl_api_key']}", timeout: 60,
                           body: {
                             longUrl: url
      }.to_json,
      headers: { "Content-Type" => "application/json"})
      json = JSON.parse(resp.body)
      json["id"]
    rescue Timeout::Error
      Rails.logger.info "Timeout error shortening url: #{url}\n"
      nil
    end
  end
end
