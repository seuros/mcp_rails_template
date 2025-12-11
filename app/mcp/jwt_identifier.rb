# frozen_string_literal: true

class JwtIdentifier < ActionMCP::GatewayIdentifier
  identifier :user
  authenticates :jwt

  def resolve
    token = extract_bearer_token
    raise Unauthorized, "JWT token required" unless token.present?

    begin
      payload = JWT.decode(token, jwt_secret, true, { algorithm: "HS256" })[0]

      user_id = payload["user_id"] || payload["sub"]
      raise Unauthorized, "Invalid JWT payload: missing user_id" unless user_id

      user = User.find_by(id: user_id)
      raise Unauthorized, "User not found" unless user

      user
    rescue JWT::DecodeError => e
      raise Unauthorized, "Invalid JWT token: #{e.message}"
    rescue JWT::ExpiredSignature
      raise Unauthorized, "JWT token has expired"
    end
  end

  private

  def jwt_secret
    ENV.fetch("ACTION_MCP_JWT_SECRET") { Rails.application.secret_key_base }
  end
end
