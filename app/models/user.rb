# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  before_create :generate_api_token

  # Generate a JWT token for MCP authentication
  def generate_jwt(expires_in: 24.hours)
    payload = {
      sub: id.to_s,
      user_id: id,
      email: email,
      exp: expires_in.from_now.to_i,
      iat: Time.current.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end

  private

  def generate_api_token
    self.api_token = SecureRandom.hex(32)
  end
end
