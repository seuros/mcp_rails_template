# frozen_string_literal: true

require "net/http"
require "uri"

class FetchWeatherByLocationTool < ApplicationMCPTool
  description "Fetch weather information by location"

  property :latitude, type: "number", description: "Latitude of the location", required: true
  property :longitude, type: "number", description: "Longitude of the location", required: true

  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  # FetchWeatherByLocationTool.new(latitude: 37.7749, longitude: -122.4194).call
  def perform
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
      render text: response.body
    end
  end

  def url
    "https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}"
  end
end
