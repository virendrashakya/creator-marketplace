module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_request!

      attr_reader :current_user

      private

      def authenticate_request!
        header = request.headers["Authorization"]
        token = header.to_s.split(" ").last if header.present?

        if token.present?
          # Try decoding as JWT
          payload = JwtService.decode(token)
          if payload && payload["sub"]
            @current_user = User.find_by(id: payload["sub"])
          else
            # Try looking up as session_token
            session_record = UserSession.active.find_by(session_token: token)
            @current_user = session_record&.user
            session_record&.touch_last_seen!
          end
        elsif session[:user_id]
          @current_user = User.find_by(id: session[:user_id])
        end

        return if @current_user.present?

        render json: { error: "Unauthorized access. Please provide a valid Bearer token." }, status: :unauthorized
      end

      def optional_authenticate_request!
        header = request.headers["Authorization"]
        token = header.to_s.split(" ").last if header.present?

        if token.present?
          payload = JwtService.decode(token)
          if payload && payload["sub"]
            @current_user = User.find_by(id: payload["sub"])
          else
            session_record = UserSession.active.find_by(session_token: token)
            @current_user = session_record&.user
            session_record&.touch_last_seen!
          end
        elsif session[:user_id]
          @current_user = User.find_by(id: session[:user_id])
        end
      end
    end
  end
end
