class Api::V1::PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[update]

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    # Always return success to prevent email enumeration
    render json: {
             message:
               "Password reset instructions sent (if user with that email address exists)."
           },
           status: :ok
  end

  def update
    if @user.update(params.permit(:password))
      render json: { message: "Password has been reset." }, status: :ok
    else
      render json: {
               error: "Invalid password reset attempt",
               details: @user.errors.full_messages
             },
             status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: {
             error: "Password reset link is invalid or has expired."
           },
           status: :unauthorized
  end
end
