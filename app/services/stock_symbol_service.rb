require "net/http"
require "uri"
require "json"

class StockSymbolService
  API_KEY = ENV["RAPIDAPI_KEY"]
  API_HOST = ENV["RAPIDAPI_HOST"]

  # search symbol from api:
  def self.symbol_search(symbol)
    url = URI("https://#{API_HOST}/query?datatype=json&keywords=#{symbol}&function=SYMBOL_SEARCH")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-key"] = API_KEY
    request["x-rapidapi-host"] = API_HOST

    response = http.request(request)
    data = JSON.parse(response.body)
    data["bestMatches"]&.first(3)

  rescue => e
    Rails.logger.error "Alpha Vantage API error: #{e.message}"
    nil
  end

  # fetch latest price from api:
  def self.latest_price(symbol)
    # to cache price results temporarily for 5 minutes
    Rails.cache.fetch("latest_price_#{symbol}", expires_in: 5.minute) do
      url = URI("https://#{API_HOST}/query?function=TIME_SERIES_DAILY&symbol=#{symbol}&outputsize=compact&datatype=json")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["x-rapidapi-key"] = API_KEY
      request["x-rapidapi-host"] = API_HOST

      response = http.request(request)
      data = JSON.parse(response.read_body)

      time_series = data["Time Series (Daily)"]
      return nil unless time_series

      latest_day = time_series.keys.first
      latest_close = time_series[latest_day]["4. close"]

      latest_close.to_f
    rescue => e
      Rails.logger.error "Alpha Vantage API error: #{e.message}"
      nil
    end
  end
end
