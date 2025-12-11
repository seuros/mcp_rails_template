# frozen_string_literal: true

class ApplicationGateway < ActionMCP::Gateway
  identified_by JwtIdentifier
end
