module Api
  module V1
    class EventsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        actor_id = current_user&.id || params[:actor_id] || 0
        return head :bad_request if params[:action_name].blank?

        EventTracker.track(
          action: params[:action_name],
          actor: actor_id,
          creator: params[:creator_id],
          target: resolve_target(params[:target_type], params[:target_id]),
          properties: params[:properties] || {},
          request: request,
          session_id: params[:session_id]
        )

        head :created
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def resolve_target(type, id)
        return nil if type.blank? || id.blank?
        klass = type.safe_constantize
        klass&.find_by(id: id)
      end
    end
  end
end
