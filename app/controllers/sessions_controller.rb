class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ create refresh ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render json: { error: "Try again later." }, status: :too_many_requests }

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      tokens = generate_tokens(user)
      render json: tokens, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def refresh
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    begin
      decoded = JwtService.decode(token)
      if decoded && decoded["type"] == "refresh"
        user = User.find(decoded["user_id"])
        tokens = generate_tokens(user)
        render json: tokens, status: :ok
      else
        render json: { error: "Invalid refresh token" }, status: :unauthorized
      end
    rescue JWT::DecodeError
      render json: { error: "Invalid refresh token" }, status: :unauthorized
    end
  end

  def destroy
    # In a JWT system, we don't need to do anything on the server side
    # The client should remove the tokens
    head :no_content
  end
end
