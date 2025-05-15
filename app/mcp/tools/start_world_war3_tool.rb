# frozen_string_literal: true

# A mock destructive tool for testing purposes.
# Simulates a high-impact operation using GPS coordinates with validation.
class StartWorldWar3Tool < ApplicationMCPTool
  tool_name "start-world-war3"
  description "Destructive test tool that accepts GPS coordinates and simulates a high-impact operation. Validates latitude and longitude are within Earth's bounds."

  destructive

  property :latitude, type: "number", description: "Latitude of launch site (-90 to 90)", required: true
  property :longitude, type: "number", description: "Longitude of launch site (-180 to 180)", required: true

  validate :validate_coordinates

  def perform
    render(text: "💥 Boom! Launch initiated from (#{latitude}, #{longitude}). World War 3 has started (geopolitically, not literally).")
  end

  private

  def validate_coordinates
    errors.add(:latitude, "must be between -90 and 90") unless latitude.between?(-90, 90)
    errors.add(:longitude, "must be between -180 and 180") unless longitude.between?(-180, 180)
  end
end
