# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Authentication

  # Add this to handle JSON parsing
  before_action :parse_json_request

  private

  def parse_json_request
    if request.content_type == "application/json"
      request.parameters.merge!(JSON.parse(request.body.read))
    end
  rescue JSON::ParserError
    render json: { error: "Invalid JSON format" }, status: :bad_request
  end
end
