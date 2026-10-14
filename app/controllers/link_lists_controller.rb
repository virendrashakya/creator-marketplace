# Link lists (4a–4c). One URL that holds a hand-picked list of links: Studio
# manages them, and /:handle/:slug is the page a fan opens.
class LinkListsController < ApplicationController
  before_action :require_user, except: :public
  before_action :set_list, only: %i[edit update destroy reorder qr]

  # 4b.
  def index
    @lists = current_user.link_lists.includes(:items, cover_attachment: :blob).order(updated_at: :desc)
    @opens = @lists.sum(&:opens_count)
    @taps = @lists.sum(&:taps_count)
    @earned = PaymentClaim.approved.where(link_list_id: @lists.map(&:id)).sum(:amount_cents)
    @live = @lists.count { |l| l.published? && l.show_on_profile? }
  end

  def new
    @list = current_user.link_lists.new(socials: current_user.social_links.map { |s| s[:key] }.first(4))
  end

  def create
    @list = current_user.link_lists.new(list_params)
    if @list.save
      redirect_to edit_link_list_path(@list), notice: "List created. Paste your first link."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 4c.
  def edit
    @collections = current_user.paid_media_collections.live.order(created_at: :desc)
    @products = current_user.product_links.to_a
  end

  def update
    attrs = list_params
    # The socials checkboxes post nothing when all are off.
    attrs[:socials] ||= [] if params[:link_list]&.key?(:socials_present)
    if @list.update(attrs)
      redirect_to edit_link_list_path(@list), notice: "Saved."
    else
      @collections = current_user.paid_media_collections.live.order(created_at: :desc)
      @products = current_user.product_links.to_a
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy
    redirect_to link_lists_path, notice: "List deleted. Its link no longer opens."
  end

  def reorder
    ids = Array(params[:ids]).map(&:to_i)
    items = @list.items.where(id: ids).index_by(&:id)
    LinkListItem.transaction { ids.each_with_index { |id, i| items[id]&.update_column(:position, i) } }
    @list.touch
    head :no_content
  end

  # A QR for the list's public URL, as a downloadable SVG.
  def qr
    svg = helpers.wf_qr_svg(public_link_list_url(current_user.handle, @list.slug), size: 512)
    send_data svg, type: "image/svg+xml", disposition: "attachment", filename: "#{current_user.handle}-#{@list.slug}-qr.svg"
  end

  # 4a. Hidden lists still open for anyone with the link; only an "off" list
  # (unpublished) is gone.
  def public
    @user = User.find_by!(handle: params[:handle].to_s.downcase)
    return head :not_found if @user.blocks?(current_user)

    @list = @user.link_lists.find_by!(slug: params[:slug].to_s.downcase)
    raise ActiveRecord::RecordNotFound unless @list.published? || current_user == @user

    # Counting opens without counting the creator previewing their own list,
    # or the editor's live preview frame.
    LinkList.where(id: @list.id).update_all("opens_count = opens_count + 1") unless current_user == @user || params[:preview]
    @items = @list.items.includes(:product_link, paid_media_collection: { paid_media_posts: [ :media_attachment, :preview_attachment ] })
                  .reject { |i| i.collection? && !i.paid_media_collection&.released? }
    @socials = @list.visible_socials
    @blog_items = @items.select { |i| i.kind == "url" && blog_url?(i) }
    @items -= @blog_items
    @cover_src = cover_src
    @collections_count = @user.live_collections.count
    @posts_count = @user.creator_posts.where(published: true).count
  end

  private

  def set_list
    @list = current_user.link_lists.find(params[:id])
  end

  def list_params
    params.fetch(:link_list, {}).permit(:title, :slug, :description, :published, :show_on_profile, :cover, socials: [])
  end

  # Posts from the creator's own blog get their own "From my blog" block.
  def blog_url?(item)
    blog = @user.blog_url.to_s.sub(%r{\Ahttps?://}i, "").delete_suffix("/")
    blog.present? && item.url.to_s.sub(%r{\Ahttps?://}i, "").start_with?(blog)
  end

  def cover_src
    return url_for(@list.cover) if @list.cover.attached?

    item = @list.fallback_image_item
    source = item&.image_source
    return source if source.is_a?(String)
    return helpers.wf_post_image_src(source) if source

    helpers.wf_banner_src(@user)
  end
end
