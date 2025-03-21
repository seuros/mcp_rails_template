# frozen_string_literal: true

class FetchWeatherByLocationTool < ApplicationMCPTool
  description "Fetch weather information by location"

  property :latitude, type: "float", description: "Latitude of the location", required: true
  property :longitude, type: "float", description: "Longitude of the location", required: true

  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  # FetchWeatherByLocationTool.new(latitude: 37.7749, longitude: -122.4194).call
  def perform
    url = URI.parse(url)
    Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(url)
      response = http.request(request)
      render text: response.body
    end
  end

  def url
    "https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}"
  end
end
