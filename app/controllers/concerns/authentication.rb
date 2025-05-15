module Authentication
  extend ActiveSupport::Concern

  JWT_SECRET = Rails.application.credentials.dig(:jwt_secret)

  included { before_action :require_authentication }

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    resume_session || authenticate_with_token
  end

  def require_authentication
    unless authenticated?
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    if cookies.signed[:session_id]
      Session.find_by(id: cookies.signed[:session_id])
    end
  end

  def authenticate_with_token
    header = request.headers["Authorization"]
    return nil unless header

    token = header.split(" ").last
    begin
      decoded_token = JWT.decode(token, JWT_SECRET, true, algorithm: "HS256")
      Current.session ||= Session.find(decoded_token.first["session_id"])
    rescue JWT::DecodeError
      nil
    end
  end

  def start_new_session_for(user)
    user
      .sessions
      .create!(user_agent: request.user_agent, ip_address: request.remote_ip)
      .tap do |session|
        Current.session = session
        token = generate_jwt_token(session)

        cookies.signed.permanent[:session_id] = {
          value: session.id,
          expires: 30.days.from_now,
          # httponly: true,
          same_site: :strict,
          secure: Rails.env.production?
        }

        @auth_token = token
      end
  end

  def generate_jwt_token(session)
    payload = {
      session_id: session.id,
      user_id: session.user_id,
      exp: 15.minutes.from_now.to_i
    }

    JWT.encode(payload, JWT_SECRET, "HS256")
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
  end
end
