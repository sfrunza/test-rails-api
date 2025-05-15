module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  class_methods do
    def skip_authentication(**options)
      skip_before_action :authenticate_request, **options
    end
  end

  private
    def authenticate_request
      header = request.headers["Authorization"]
      token = header.split(" ").last if header

      begin
        decoded = JwtService.decode(token)
        if decoded && decoded["type"] == "access"
          @current_user = User.find(decoded["user_id"])
        else
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      rescue JWT::DecodeError
        render json: { error: "Invalid token" }, status: :unauthorized
      end
    end

    def authenticate_user
      unless current_user
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def generate_tokens(user)
      JwtService.generate_tokens(user)
    end
end
