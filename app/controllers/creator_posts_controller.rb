# Free, public posts. Studio's Posts screen (5e) is the grid plus a composer;
# the public post page is what a fan opens from the Posts tab.
class CreatorPostsController < ApplicationController
  before_action :require_user, except: :show
  before_action :set_post, only: %i[edit update destroy]

  def index
    load_studio_posts
    @creator_post = current_user.creator_posts.new(published: true)

    respond_to do |format|
      format.html
      format.csv do
        require "csv"
        csv_data = CSV.generate(headers: true) do |csv|
          csv << ["ID", "Title / Asset", "Type", "Status", "Publish Date", "Views", "Likes", "Comments", "Revenue (Est.)", "Teased Collection"]
          @posts.each do |p|
            csv << [
              p.asset_code,
              p.title,
              p.item_type,
              p.published? ? "Published" : "Draft",
              p.created_at.strftime("%b %d, %Y %I:%M %p"),
              p.views_count.to_i,
              p.likes_count.to_i,
              p.comments_count.to_i,
              "₹#{(p.revenue_cents / 100.0).round(2)}",
              p.paid_media_collection&.title
            ]
          end
        end
        send_data csv_data, filename: "creator-posts-audit-#{Date.today}.csv", type: "text/csv"
      end
    end
  end

  def new
    @creator_post = current_user.creator_posts.new(published: true)
    @collections = current_user.paid_media_collections.order(created_at: :desc)
  end

  def create
    @creator_post = current_user.creator_posts.new(post_params)
    process_post_type_metadata(@creator_post)

    if @creator_post.save
      redirect_to creator_posts_path, notice: @creator_post.published? ? "Post published successfully." : "Post saved as draft."
    else
      @collections = current_user.paid_media_collections.order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find_by!(handle: params[:handle].to_s.downcase)
    return head :not_found if @user.blocks?(current_user)

    scope = current_user == @user ? @user.creator_posts : @user.creator_posts.where(published: true)
    @post = scope.includes(:creator_post_likes, creator_post_comments: :user).find(params[:id])
  end

  def edit
    @collections = current_user.paid_media_collections.order(created_at: :desc)
  end

  def update
    @creator_post.assign_attributes(post_params)
    process_post_type_metadata(@creator_post)

    if @creator_post.save
      redirect_to creator_posts_path, notice: "Post updated successfully."
    else
      @collections = current_user.paid_media_collections.order(created_at: :desc)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @creator_post.destroy
    redirect_to creator_posts_path, notice: "Post removed."
  end

  private

  def load_studio_posts
    @posts = current_user.creator_posts.with_attached_media.includes(:creator_post_likes, :paid_media_collection).order(created_at: :desc)
    @collections = current_user.paid_media_collections.order(created_at: :desc)
  end

  def set_post
    @creator_post = current_user.creator_posts.find(params[:id])
  end

  def post_params
    params.require(:creator_post).permit(:body, :media, :published, :paid_media_collection_id, :post_type, tags: [])
  end

  def process_post_type_metadata(post)
    ptype = post.post_type.presence || "post"
    meta = (post.metadata || {}).dup

    # Title & Content
    if params[:post_title].present?
      meta["title"] = params[:post_title].to_s.strip
    end

    if params[:badge].present?
      meta["badge"] = params[:badge].to_s.strip
    end

    # Visibility & Cadence Controls
    meta["visibility"] = params[:visibility].presence || meta["visibility"] || "public"
    meta["timing"] = params[:timing].presence || meta["timing"] || "immediate"
    meta["pin_to_profile"] = params[:pin_to_profile].in?(["1", "true", true])
    meta["vip_whisper_alert"] = params[:vip_whisper_alert].in?(["1", "true", true])
    meta["dynamic_watermark"] = params[:dynamic_watermark].in?(["1", "true", true])

    case ptype
    when "poll"
      q = params[:poll_question].presence || post.body.to_s.sub(/^(GRWM poll|Poll):\s*/i, "")
      opt1 = params[:poll_option_1].presence || "Option 1"
      opt2 = params[:poll_option_2].presence || "Option 2"
      dur = params[:poll_duration].presence || "24 hours"
      meta["poll_question"] = q
      meta["poll_options"] = [opt1, opt2]
      meta["poll_duration"] = dur
      meta["badge"] = params[:badge].presence || "INTERACTIVE RUNWAY POLL"
      post.body = "Poll: #{q}" if post.body.blank?
    when "audio"
      meta["audio_title"] = params[:audio_title].presence || "Bedside Confessions (Uncut)"
      meta["audio_format"] = params[:audio_format].presence || "3D Binaural • FLAC Lossless"
      meta["badge"] = params[:badge].presence || "AUDIO WHISPER DROP"
    when "video_teaser"
      meta["badge"] = params[:badge].presence || "60FPS 4K UHD TEASER"
    when "post"
      meta["badge"] = params[:badge].presence || (post.video? ? "60FPS 4K UHD REEL" : "4K UHD • RAW EDIT")
    end

    if params[:tags_string].present?
      parsed_tags = params[:tags_string].to_s.split(/[,\s]+/).map { |t| t.strip.start_with?("#") ? t.strip : "##{t.strip}" }.reject(&:blank?)
      post.tags = parsed_tags if parsed_tags.any?
    end

    # Wardrobe tags
    if params[:wardrobe_tags].is_a?(Array)
      meta["wardrobe_tags"] = params[:wardrobe_tags]
    elsif params[:wardrobe_tags_json].present?
      begin
        meta["wardrobe_tags"] = JSON.parse(params[:wardrobe_tags_json])
      rescue JSON::ParserError
      end
    end

    post.metadata = meta
  end
end
