module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :require_user

      def index
        notifications = current_user.notifications.recent.limit(50)
        unread_count = current_user.notifications.unread.count

        render json: {
          unread_count: unread_count,
          notifications: notifications.map do |n|
            {
              id: n.id,
              kind: n.kind,
              data: n.data,
              read: !n.unread?,
              created_at: n.created_at,
              actor: n.actor ? { id: n.actor.id, name: n.actor.name, handle: n.actor.handle } : nil
            }
          end
        }
      end

      def read
        notification = current_user.notifications.find_by(id: params[:id])
        notification&.mark_as_read!
        head :ok
      end

      def read_all
        current_user.notifications.unread.update_all(read_at: Time.current)
        head :ok
      end
    end
  end
end
