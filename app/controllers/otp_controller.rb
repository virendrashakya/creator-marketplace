# One WhatsApp OTP flow behind three doors:
#
#   creator  /start, signing up a new page (6a → 6b → onboarding)
#   sign_in  /sign_in, anyone coming back
#   fan      /join, a fan who only needs an account because they are paying
#            (6f): phone and handle in one step, then straight back to pay
#
# What the person was doing rides in the session between "send" and
# "verify", never in a hidden field, so a verified phone cannot be swapped
# for another between the two requests.
class OtpController < ApplicationController
  INTENTS = %w[creator sign_in fan].freeze

  # 6f. The fan's one quick step.
  def join
    return redirect_to(safe_return_to(params[:return_to]) || root_path) if signed_in?

    @return_to = safe_return_to(params[:return_to])
    @creator = creator_from_return_to(@return_to)
  end

  def create
    intent = params[:intent].presence_in(INTENTS) || "sign_in"
    phone = User.normalize_phone(params[:phone])
    return_to = safe_return_to(params[:return_to])

    unless phone&.match?(/\A\+91[6-9]\d{9}\z/) || phone&.match?(/\A\+(?!91)\d{10,15}\z/)
      return back_with_error(intent, return_to, "Enter a valid mobile number.")
    end

    if intent == "fan"
      handle = params[:handle].to_s.downcase.strip.delete_prefix("@")
      existing = User.find_by(phone_number: phone)
      if existing.nil?
        probe = User.new(handle: handle)
        probe.valid?
        if probe.errors[:handle].any?
          return back_with_error(intent, return_to, "That handle #{probe.errors[:handle].first}.")
        end
      end
    end

    session[:otp] = { "phone" => phone, "intent" => intent, "handle" => handle,
                      "return_to" => return_to, "whatsapp" => params[:whatsapp_updates] == "1" }
    send_code(phone)
    redirect_to verify_otp_path
  end

  # 6b. Six boxes.
  def edit
    @pending = session[:otp]
    return redirect_to(sign_in_path) unless @pending

    @latest = OtpCode.latest_for(@pending["phone"])
  end

  def update
    @pending = session[:otp]
    return redirect_to(sign_in_path) unless @pending

    phone = @pending["phone"]
    unless OtpCode.verify(phone, params[:code])
      @latest = OtpCode.latest_for(phone)
      left = @latest ? [ OtpCode::MAX_ATTEMPTS - @latest.attempts, 0 ].max : 0
      flash.now[:alert] = left.positive? ? "That code isn't right. #{left} #{"try".pluralize(left)} left." : "Too many tries. Send a new code."
      return render(:edit, status: :unprocessable_entity)
    end

    session.delete(:otp)
    user = User.find_by(phone_number: phone)

    if user
      user.update_columns(phone_verified_at: Time.current) unless user.phone_verified_at
      sign_in!(user)
      return redirect_to(onboarding_profile_path) if user.creator? && user.onboarded_at.nil? && @pending["intent"] == "creator"

      redirect_to(@pending["return_to"] || (user.creator? ? dashboard_path : root_path), notice: "Welcome back, #{user.first_name}.")
    elsif @pending["intent"] == "creator"
      session[:verified_phone] = phone
      redirect_to onboarding_profile_path
    elsif @pending["intent"] == "fan"
      # notify_whatsapp_claims is "tell me on WhatsApp": for a fan, that
      # their unlock was approved.
      user = User.new(name: @pending["handle"], handle: @pending["handle"], phone_number: phone,
                      phone_verified_at: Time.current, account_type: "personal",
                      notify_whatsapp_claims: @pending["whatsapp"] == true)
      user.assign_unusable_password
      if user.save
        sign_in!(user)
        redirect_to(@pending["return_to"] || root_path)
      else
        redirect_to fan_join_path(return_to: @pending["return_to"]), alert: user.errors.full_messages.to_sentence
      end
    else
      session[:verified_phone] = phone
      redirect_to onboarding_profile_path, notice: "That number isn't on Wishful yet. Let's make your page."
    end
  end

  def resend
    pending = session[:otp]
    return redirect_to(sign_in_path) unless pending

    latest = OtpCode.latest_for(pending["phone"])
    if latest && latest.resend_available_at > Time.current
      return redirect_to(verify_otp_path, alert: "Wait a few seconds before asking for another code.")
    end

    send_code(pending["phone"], via: params[:via])
    redirect_to verify_otp_path, notice: "New code sent."
  end

  private

  def send_code(phone, via: nil)
    latest = OtpCode.latest_for(phone)
    # A double-tap on "Get OTP" must not send two codes.
    return if latest && latest.consumed_at.nil? && latest.resend_available_at > Time.current

    _record, code = OtpCode.issue!(phone)
    result = WhatsappClient.send_otp(phone, code)
    # With no WhatsApp provider configured, a developer still needs the
    # code. It is in the log; in development it is also shown on screen.
    flash[:notice] = "Development: your code is #{code}" if result == :logged && Rails.env.development?
  end

  # A fresh session on every sign-in, so a session id fixed before it is
  # worthless after.
  def sign_in!(user)
    reset_session
    session[:user_id] = user.id
  end

  def back_with_error(intent, return_to, message)
    path = case intent
    when "fan" then fan_join_path(return_to: return_to)
    when "creator" then start_path
    else sign_in_path
    end
    redirect_to path, alert: message
  end

  # Only ever a path on this site. Taking a full URL from a parameter would
  # be an open redirect.
  def safe_return_to(value)
    path = value.to_s
    path.start_with?("/") && !path.start_with?("//") && !path.include?("\\") ? path : nil
  end

  # /pay/PaidMediaCollection/3 -> that collection's creator, for the backdrop.
  def creator_from_return_to(path)
    match = path.to_s.match(%r{\A/pay/(\w+)/(\d+)})
    return nil unless match && PaymentClaimsController::PURCHASABLES.key?(match[1])

    record = match[1].constantize.find_by(id: match[2])
    record.is_a?(MeetSlot) ? record.meet_offer.user : (record.try(:user) || record.try(:wishlist)&.user)
  end
end
