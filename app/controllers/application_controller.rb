class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Authentication
  include Pundit::Authorization

  skip_before_action :require_authentication,
                     only: %i[health_check],
                     if: -> { action_name == "health_check" }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def health_check
    render json: { status: "ok" }
  end

  private

  def user_not_authorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def pundit_user
    Current.user
  end
end
