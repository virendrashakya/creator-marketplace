module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_request!, only: %i[send_otp verify_otp]

      def send_otp
        phone = User.normalize_phone(params[:phone])
        unless phone&.match?(/\A\+91[6-9]\d{9}\z/) || phone&.match?(/\A\+(?!91)\d{10,15}\z/)
          return render json: { error: "Enter a valid mobile number." }, status: :unprocessable_entity
        end

        _record, code = OtpCode.issue!(phone, purpose: "fan_sign_in")
        WhatsappClient.send_otp(phone, code)

        # In development/test mode, return debug code for convenience
        resp = { success: true, message: "Code sent to #{phone}" }
        resp[:debug_code] = code if Rails.env.development? || Rails.env.test?
        render json: resp
      end

      def verify_otp
        phone = User.normalize_phone(params[:phone])
        code = params[:code].to_s.strip

        unless OtpCode.verify(phone, code)
          return render json: { error: "Invalid or expired 6-digit code. Try again." }, status: :unprocessable_entity
        end

        # Find or create fan user
        user = User.find_by(phone_number: phone)
        if user.nil?
          base_handle = params[:handle].presence || "fan_#{phone.last(4)}"
          clean_handle = base_handle.to_s.downcase.gsub(/[^a-z0-9_]/, "")
          clean_handle = "fan_#{SecureRandom.hex(3)}" if clean_handle.blank?

          # Ensure uniqueness
          counter = 1
          final_handle = clean_handle
          while User.exists?(handle: final_handle)
            final_handle = "#{clean_handle}#{counter}"
            counter += 1
          end

          user = User.create!(
            phone_number: phone,
            handle: final_handle,
            name: params[:name].presence || final_handle,
            account_type: "personal",
            password: SecureRandom.hex(16),
            phone_verified_at: Time.current
          )
        end

        # Create session tracking record
        device_type = request.headers["X-Requested-With"] == "wishful-pwa" ? "pwa" : "web"
        ip_hash = Digest::SHA256.hexdigest(request.remote_ip.to_s)[0..15] if request.remote_ip.present?

        session_record = UserSession.create!(
          user: user,
          device_type: device_type,
          user_agent: request.user_agent,
          ip_hash: ip_hash,
          platform: params[:platform] || "unknown",
          expires_at: 30.days.from_now,
          last_seen_at: Time.current
        )

        jwt_token = JwtService.encode(user)

        # Track sign in event
        EventTracker.track(
          action: "sign_in",
          actor: user.id,
          request: request,
          session_id: session_record.session_token
        )

        render json: {
          token: jwt_token,
          session_token: session_record.session_token,
          user: {
            id: user.id,
            name: user.name,
            handle: user.handle,
            account_type: user.account_type,
            avatar_url: user.avatar_url,
            phone_number: user.phone_number
          }
        }
      end

      def me
        unread_notifications = current_user.notifications.unread.count
        active_subs = current_user.creator_subscriptions.where(status: "active").count
        unlocks_count = current_user.access_purchases.where(status: "paid").count + current_user.media_purchases.where(status: "paid").count

        render json: {
          user: {
            id: current_user.id,
            name: current_user.name,
            handle: current_user.handle,
            account_type: current_user.account_type,
            avatar_url: current_user.avatar_url,
            phone_number: current_user.phone_number,
            unread_notifications_count: unread_notifications,
            active_subscriptions_count: active_subs,
            total_unlocks_count: unlocks_count
          }
        }
      end

      def destroy
        header = request.headers["Authorization"]
        token = header.to_s.split(" ").last if header.present?
        session_record = UserSession.find_by(session_token: token) if token
        session_record&.revoke!
        head :ok
      end
    end
  end
end
