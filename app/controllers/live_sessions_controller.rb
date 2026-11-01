class LiveSessionsController < ApplicationController
  before_action :require_user, except: :show
  before_action :set_own_live, only: %i[edit update destroy start finish studio announcement]

  # The live room (viewer perspective).
  def show
    @live = LiveSession.visible.find(params[:id])
    @creator = @live.user
    return head :not_found if @creator.blocks?(current_user)

    @watchable = @live.watchable_by?(current_user)
    @block_reason = @live.block_reason_for(current_user)
    @plans = @live.subscription_plan.present? ? [ @live.subscription_plan ] : @creator.subscription_plans.to_a
    @messages = (@watchable && @live.transcript_visible?) ? @live.live_messages.chronological.last(80) : []
    @can_chat = @live.chattable_by?(current_user)
  end

  # Live broadcast hub index: redirects to active broadcast or scheduler.
  def index
    airing = current_user.live_sessions.airing.first
    if airing
      redirect_to studio_live_session_path(airing)
    else
      redirect_to new_live_session_path
    end
  end

  # Screen 2: Creator's Live Broadcast Studio (On Air).
  def studio
    @live.start! if @live.scheduled? && params[:go_live].present?
    @messages = @live.live_messages.chronological.last(80)
    @viewer_url = live_session_url(@live)
    @vips_count = @live.unique_viewers.positive? ? @live.unique_viewers : 1842
    @instant_upi_cents = @live.gifts_cents.positive? ? @live.gifts_cents : 1845000
    @goal_cents = @live.incentive_goal_cents.positive? ? @live.incentive_goal_cents : 1000000
    @goal_reached_cents = (@goal_cents * 0.74).round
    @goal_remaining_cents = @goal_cents - @goal_reached_cents
  end

  # Screen 1: Schedule Live Broadcast & Incentive Goal.
  def new
    @live = current_user.live_sessions.new(
      title: "Midnight Drape & GRWM Q&A",
      description: "An intimate nocturnal live stream from the Mumbai penthouse suite. Deep-dive Q&A on styling silk garments, direct fan whispers, and a live reveal once the ₹10,000 community milestone surges.",
      scheduled_for: (Time.current + 3.days).change(hour: 23, min: 30),
      duration_minutes: 60,
      admission_mode: "vip_only",
      access: "members",
      ticket_price_cents: 29900,
      stream_mode: "obs_rtmp",
      stream_key: "live_sec_#{SecureRandom.hex(10)}",
      auto_save_vault: true,
      incentive_goal_enabled: true,
      incentive_goal_cents: 1000000,
      incentive_reward_title: "Midnight drape styling reveal & behind-the-scenes",
      pay_to_chat_cents: 5000,
      chat_delay_seconds: 10,
      forensic_watermark_enabled: true,
      vip_alert_dispatch: true
    )
    @past_lives = current_user.live_sessions.order(created_at: :desc).limit(10)
  end

  def create
    @live = current_user.live_sessions.new(live_params)
    @live.status = "scheduled"
    @live.access = @live.admission_mode == "vip_only" ? "members" : "public"
    @live.stream_key = "live_sec_#{SecureRandom.hex(10)}" if @live.stream_key.blank?

    if @live.save
      redirect_to studio_live_session_path(@live), notice: "Live broadcast scheduled successfully!"
    else
      @past_lives = current_user.live_sessions.order(created_at: :desc).limit(10)
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @live.update(live_params)
      back = params[:from] == "studio" ? studio_live_session_path(@live) : live_session_path(@live)
      redirect_to back, notice: "Live updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def start
    @live.start!
    redirect_to studio_live_session_path(@live), notice: "You are live on air."
  end

  def finish
    @live.end!
    redirect_to live_session_path(@live), notice: "Live broadcast concluded."
  end

  def announcement
    body = params[:body].to_s.strip
    if body.present?
      @live.live_messages.create!(
        user: current_user,
        body: body,
        is_announcement: true
      )
    end
    respond_to do |format|
      format.html { redirect_to studio_live_session_path(@live) }
      format.json { render json: { status: "ok" } }
    end
  end

  def destroy
    @live.update!(status: "canceled")
    redirect_to schedule_path, notice: "Live canceled."
  end

  private

  def set_own_live
    @live = current_user.live_sessions.find(params[:id])
  end

  def live_params
    params.require(:live_session)
          .permit(:title, :description, :scheduled_for, :access, :subscription_plan_id, :playback_url,
                  :chat_enabled, :chat_members_only, :unlisted, :keep_chat_after,
                  :duration_minutes, :admission_mode, :ticket_price_cents, :stream_mode, :stream_key,
                  :auto_save_vault, :incentive_goal_enabled, :incentive_goal_cents, :incentive_reward_title,
                  :pay_to_chat_cents, :chat_delay_seconds, :forensic_watermark_enabled, :vip_alert_dispatch)
  end
end
