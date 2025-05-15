class Api::V1::SessionsController < ApplicationController
  skip_authentication only: %i[ create refresh ]
  rate_limit to: 10,
             within: 3.minutes,
             only: :create,
             with: -> do
               render json: {
                        error: "Too many attempts. Try again later."
                      },
                      status: :too_many_requests
             end

  def create
    user = User.find_by(email_address: params[:email_address])

    if user&.authenticate(params[:password])
      if user.active?
        start_new_session_for(user)
        render json: {
                 token: @auth_token,
                 user:
                   user.as_json(
                     only: %i[id first_name last_name email_address role]
                   )
               },
               status: :created
      else
        render json: { error: "Account is not active" }, status: :forbidden
      end
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def show
    if Current.session
      render json:
               Current.session.user.as_json(
                 only: %i[id first_name last_name email_address role]
               ),
             status: :ok
    else
      render json: { error: "Please login" }, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    render json: { message: "Logged out successfully" }, status: :ok
  end

  def refresh_token
    if Current.session
      new_token = generate_jwt_token(Current.session)
      render json: { token: new_token }, status: :ok
    else
      render json: { error: "Invalid session" }, status: :unauthorized
    end
  end
end
