# Collections, both sides.
#
# Fans: `show` is the collection page (cover visible, the rest locked, one
# price and one button), `viewer` is the watermarked full-screen viewer once
# it is theirs.
#
# Creators: `index` is Studio's grid, `edit` is the editor where items are
# uploaded, reordered and priced.
class PaidMediaCollectionsController < ApplicationController
  before_action :require_user, except: %i[show viewer]
  before_action :set_collection, only: %i[edit update destroy items reorder remove_item]
  before_action :load_public_collection, only: %i[show viewer]

  def index
    @collections = current_user.paid_media_collections
                               .includes(:access_purchases, paid_media_posts: [ :media_attachment, :preview_attachment ])
                               .order(created_at: :desc)
    @drops = current_user.paid_media_posts.standalone.includes(:media_purchases).order(created_at: :desc)
  end

  def new
    @paid_media_collection = current_user.paid_media_collections.new(
      currency: "INR", published: false, subscription_plan: current_user.close_friends_plan
    )
  end

  # A collection starts life as a draft holding nothing; the editor is where
  # the photos go in.
  def create
    @paid_media_collection = current_user.paid_media_collections.new(collection_params)
    @paid_media_collection.published = false if @paid_media_collection.published.nil?
    if @paid_media_collection.save
      redirect_to edit_paid_media_collection_path(@paid_media_collection), notice: "Collection created. Add the photos fans unlock."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @items = @paid_media_collection.paid_media_posts.with_attached_media.with_attached_preview
  end

  def update
    if @paid_media_collection.update(collection_params)
      notice = if @paid_media_collection.scheduled?
        "Scheduled for #{@paid_media_collection.release_at.strftime("%-d %b, %-l:%M %p")}."
      elsif @paid_media_collection.published?
        "Saved. It's live on your profile."
      else
        "Saved as a draft."
      end
      redirect_to edit_paid_media_collection_path(@paid_media_collection), notice: notice
    else
      @items = @paid_media_collection.paid_media_posts
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @paid_media_collection.destroy
    redirect_to paid_media_collections_path, notice: "Collection removed."
  end

  # Several files at once from the editor's drop zone. Each becomes an item
  # appended after the existing ones.
  def items
    files = Array(params[:files]).compact_blank
    return redirect_to(edit_paid_media_collection_path(@paid_media_collection), alert: "Choose at least one photo or video.") if files.empty?

    next_position = @paid_media_collection.paid_media_posts.maximum(:position).to_i + 1
    added = 0
    errors = []
    files.first(50).each_with_index do |file, i|
      video = file.content_type.to_s.start_with?("video/")
      post = current_user.paid_media_posts.new(
        paid_media_collection: @paid_media_collection,
        title: "#{@paid_media_collection.title} · #{next_position + i}",
        media_type: video ? "video" : "image",
        currency: @paid_media_collection.currency,
        position: next_position + i,
        published: true
      )
      post.media.attach(file)
      post.save ? added += 1 : errors << post.errors.full_messages.to_sentence
    end

    if errors.any?
      redirect_to edit_paid_media_collection_path(@paid_media_collection), alert: "Added #{added}. #{errors.uniq.first}"
    else
      redirect_to edit_paid_media_collection_path(@paid_media_collection), notice: "Added #{added} #{"item".pluralize(added)}."
    end
  end

  # Drag-to-reorder from the editor. The first id becomes the public cover.
  def reorder
    ids = Array(params[:ids]).map(&:to_i)
    posts = @paid_media_collection.paid_media_posts.where(id: ids).index_by(&:id)
    PaidMediaPost.transaction do
      ids.each_with_index { |id, i| posts[id]&.update_column(:position, i) }
    end
    head :no_content
  end

  def remove_item
    post = @paid_media_collection.paid_media_posts.find(params[:post_id])
    post.destroy
    redirect_to edit_paid_media_collection_path(@paid_media_collection), notice: "Removed from the collection."
  end

  # ---- fan side ----

  def show
    @items = @collection.paid_media_posts.to_a
    @unlocked = @collection.unlocked_for?(current_user)
    @own = current_user == @user
    @plan = @collection.subscription_plan
    @pending_claim = current_user && current_user.payment_claims.pending
                                                 .find_by(purchasable: @collection)
    # Same count the storefront's Close Friends bar uses: collections plus
    # drops sold on their own.
    @all_count = @user.live_collections.count + @user.paid_media_posts.published.standalone.count
    @list_id = params[:list].presence
  end

  def viewer
    @items = @collection.paid_media_posts.to_a
    unless @collection.unlocked_for?(current_user)
      return redirect_to(public_collection_path(@user.handle, @collection), alert: "Unlock this collection to see everything inside.")
    end

    @index = params[:i].to_i.clamp(0, [ @items.size - 1, 0 ].max)
    @item = @items[@index]
    @back_path = public_collection_path(@user.handle, @collection)
    @title = @collection.title
    render "shared/viewer"
  end

  private

  def set_collection
    @paid_media_collection = current_user.paid_media_collections.find(params[:id])
  end

  def load_public_collection
    @user = User.find_by!(handle: params[:handle].to_s.downcase)
    return head :not_found if @user.blocks?(current_user)

    scope = current_user == @user ? @user.paid_media_collections : @user.paid_media_collections.live
    @collection = scope.find(params[:id])
  end

  def collection_params
    permitted = params.require(:paid_media_collection)
                      .permit(:title, :description, :price_cents, :price_rupees, :currency, :published,
                              :subscription_plan_id, :release_at, :allow_downloads, :include_in_close_friends)
    # The editor asks for rupees and a Close Friends switch, the way a
    # creator thinks; the model stores paise and a plan id.
    if permitted.key?(:price_rupees)
      rupees = permitted.delete(:price_rupees).to_s.gsub(/[^0-9.]/, "")
      permitted[:price_cents] = rupees.present? ? (rupees.to_f * 100).round : nil
    end
    if permitted.key?(:include_in_close_friends)
      include_cf = permitted.delete(:include_in_close_friends) == "1"
      permitted[:subscription_plan_id] = include_cf ? current_user.close_friends_plan&.id : nil
    end
    permitted
  end
end
