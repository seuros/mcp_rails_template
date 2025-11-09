# frozen_string_literal: true

# Example ApplicationGateway showing modern GatewayIdentifier API
#
# This gateway uses the NoneIdentifier for development (no authentication required).
# For production, implement custom identifiers like ApiKeyIdentifier or JwtIdentifier.
#
# Example custom identifier:
#
#   class MyCustomIdentifier < ActionMCP::GatewayIdentifier
#     def self.auth_method
#       :my_auth
#     end
#
#     def resolve
#       # Your authentication logic here
#       extract_api_key || raise Unauthorized, "Missing API key"
#     end
#
#     private
#
#     def extract_api_key
#       request.headers["X-API-Key"]
#     end
#   end

class ApplicationGateway < ActionMCP::Gateway
  # Configure which authentication identifiers this gateway accepts
  # For development, use NoneIdentifier (no authentication required)
  # For production, use ApiKeyIdentifier, JwtIdentifier, or custom identifiers
  identified_by ActionMCP::NoneIdentifier

  # Optional: Override apply_profile_from_authentication to switch profiles based on user
  def apply_profile_from_authentication(identities)
    # Example: Switch to minimal profile for non-admin users
    # if identities[:user]&.admin?
    #   use_profile(:admin)
    # else
    #   use_profile(:minimal)
    # end
  end
end
