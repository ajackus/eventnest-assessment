class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end

  def current_user
    @current_user ||= authenticate_user_from_header
  end

  def authenticate_user_from_header
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    return nil unless token

    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
      User.find(decoded[0]["user_id"])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end
  end
end
