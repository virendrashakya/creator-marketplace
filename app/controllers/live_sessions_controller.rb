class LiveSessionsController < ApplicationController
  before_action :require_user, except: :show
  before_action :set_own_live, only: %i[edit update destroy start finish studio]

  # The live room. Public so a non-member can land on the link from a story
  # and see what they would be paying for; the stream itself is gated inside.
  def show
    @live = LiveSession.visible.find(params[:id])
    @creator = @live.user
    return head :not_found if @creator.blocks?(current_user)

    @watchable = @live.watchable_by?(current_user)
    @block_reason = @live.block_reason_for(current_user)
    # Plans to offer someone who cannot watch. One specific plan if the live
    # names one, otherwise whatever the creator sells.
    @plans = @live.subscription_plan.present? ? [ @live.subscription_plan ] : @creator.subscription_plans.to_a

    # The transcript is only sent to people allowed to see the room, and only
    # the tail: a two-hour live can hold thousands of lines.
    @messages = (@watchable && @live.transcript_visible?) ? @live.live_messages.chronological.last(80) : []
    @can_chat = @live.chattable_by?(current_user)
  end

  # The creator's own control room: go live, stop, flip the interaction and
  # privacy switches, and watch the chat without the paywall furniture a
  # viewer sees. Separate from #show because what a creator needs mid-stream
  # is controls, and what a viewer needs is the video.
  def studio
    @messages = @live.live_messages.chronological.last(80)
    @viewer_url = live_session_url(@live)
  end

  def new
    @live = current_user.live_sessions.new(scheduled_for: 1.day.from_now.change(min: 0))
  end

  def create
    @live = current_user.live_sessions.new(live_params)
    if @live.save
      redirect_to live_session_path(@live), notice: "Live scheduled."
    else
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

  # Going live and ending are separate actions rather than a status field in
  # the form: they are one-tap things a creator does from their phone at the
  # moment it happens, and they set timestamps.
  def start
    @live.start!
    redirect_to studio_live_session_path(@live), notice: "You are live."
  end

  def finish
    @live.end!
    redirect_to live_session_path(@live), notice: "Live ended."
  end

  def destroy
    # Cancelled rather than deleted: people may have it in their calendar,
    # and the chat transcript is a record.
    @live.update!(status: "canceled")
    redirect_to inline_edit_redirect(dashboard_path), notice: "Live canceled."
  end

  private

  def set_own_live
    @live = current_user.live_sessions.find(params[:id])
  end

  def live_params
    params.require(:live_session)
          .permit(:title, :description, :scheduled_for, :access, :subscription_plan_id, :playback_url,
                  :chat_enabled, :chat_members_only, :unlisted, :keep_chat_after)
  end
end
