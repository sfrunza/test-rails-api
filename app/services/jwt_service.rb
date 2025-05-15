class JwtService
  HMAC_SECRET = Rails.application.credentials.secret_key_base
  ALGORITHM = "HS256".freeze

  def self.encode(payload)
    JWT.encode(payload, HMAC_SECRET, ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, HMAC_SECRET, true, { algorithm: ALGORITHM }).first
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def self.generate_tokens(user)
    access_token = encode(
      user_id: user.id,
      exp: 1.hour.from_now.to_i,
      type: "access"
    )

    refresh_token = encode(
      user_id: user.id,
      exp: 7.days.from_now.to_i,
      type: "refresh"
    )

    {
      access_token: access_token,
      refresh_token: refresh_token,
      token_type: "Bearer",
      expires_in: 3600
    }
  end
end
