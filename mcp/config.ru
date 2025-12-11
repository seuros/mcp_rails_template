# frozen_string_literal: true

# Load the Rails environment
require_relative "../config/environment"

# Ensure STDOUT is not buffered
$stdout.sync = true # for falcon

# Handle signals gracefully
Signal.trap("INT") do
  puts "\nReceived interrupt signal. Shutting down gracefully..."
  exit(0)
end

Signal.trap("TERM") do
  puts "\nReceived termination signal. Shutting down gracefully..."
  exit(0)
end

# Run the server directly
run ActionMCP.server
