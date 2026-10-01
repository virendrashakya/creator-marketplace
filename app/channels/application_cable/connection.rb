module ApplicationCable
  # The socket is authenticated from the same session cookie the rest of the
  # app uses, so a websocket can never be more trusted than a request. An
  # unidentified visitor is rejected outright rather than connected as nil,
  # because every channel here has a paywall behind it and "no user" must
  # fail closed.
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      user_id = request.session[:user_id]
      user = User.find_by(id: user_id) if user_id
      user || reject_unauthorized_connection
    end
  end
end
