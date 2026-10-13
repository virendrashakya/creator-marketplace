class ProfilesController < ApplicationController
  # Below this many recommendations, search and category chips are noise.
  # Wishlink's creators have thousands of items and need both; a creator with
  # twelve links does not.
  FILTER_THRESHOLD = 12

  def show
    handle = params[:handle].to_s.delete_prefix("@")
    @user = User.find_by!(handle: handle)
    return head :not_found if @user.blocks?(current_user)

    @collections = @user.link_collections.includes(:product_links)
    @uncategorized_links = @user.product_links.where(link_collection_id: nil)
    @paid_media_posts = @user.paid_media_posts.published.order(created_at: :desc)
    @wishlists = @user.wishlists.where(published: true).includes(:wishlist_items)
    @contact_reveals = @user.contact_reveals.published.order(:created_at)
    @meet_offers = @user.meet_offers.published.includes(:meet_slots).order(:created_at)
    @creator_posts = @user.creator_posts.where(published: true).includes(:creator_post_likes, creator_post_comments: :user).order(created_at: :desc)

    @following = current_user.present? && current_user != @user && current_user.following?(@user)
    @own_page = current_user == @user

    # Search and category filters only earn their space once a page has enough
    # items that scrolling hurts. Below the threshold they are chrome that
    # makes a small page look empty.
    @all_links = @collections.flat_map(&:product_links) + @uncategorized_links.to_a
    @filterable = @all_links.size >= FILTER_THRESHOLD

    # Collection names double as category chips: a creator who grouped their
    # links has already named their own categories.
    @categories = @collections.reject { |c| c.product_links.empty? }
    @query = params[:q].to_s.strip
    if @query.present?
      needle = @query.downcase
      @matched_links = @all_links.select do |l|
        [ l.title, l.description, l.merchant ].compact.any? { |v| v.downcase.include?(needle) }
      end
    end

    # Which sections actually have something in them. The tab bar is built from
    # this, so it can never offer an empty tab.
    #
    # Order matters: the first one with content becomes the default tab, and
    # what a fan should see first is the creator's own work, not a catalogue
    # of other people's products.
    # Tab labels stay short and generic even when a creator renames a section:
    # "Behind the haul" is a good heading and a terrible tab. The heading is
    # theirs, the tab label is ours, and they are allowed to differ.
    @paid_media_collections = @user.paid_media_collections.published.order(created_at: :desc)
    @subscription_plans = @user.subscription_plans.where(active: true).order(:price_cents)

    # Five dedicated tabs on the creator/fan page:
    # 1. Posts: all updates and feed
    # 2. Recommendations: recommended products and referral links
    # 3. Vault: exclusive paywalled drops, uncut sets, Close Friends / VIP tiers
    # 4. Wishlist: fan gifting lists
    # 5. About: creator bio, reach, booking time slots & direct contact ("Sell your time and reach")
    vault_count = @paid_media_posts.size + @subscription_plans.size
    @sections = [
      { id: "posts",           label: "Posts",           icon: "post" },
      { id: "vault",           label: "Vault",           icon: "vault", badge: (vault_count > 0 ? "VIP" : nil) },
      { id: "recommendations", label: "Recommendations", icon: "shop" },
      { id: "wishlist",        label: "Wishlist",        icon: "gift" },
      { id: "about",           label: "About",           icon: "about" }
    ]

    tab_aliases = {
      "feed"        => "posts",
      "shop"        => "recommendations",
      "collections" => "vault",
      "unlock"      => "vault",
      "media"       => "vault",
      "exclusives"  => "vault",
      "gifts"       => "wishlist",
      "time"        => "about"
    }

    requested = params[:tab].to_s.downcase
    requested = tab_aliases[requested] || requested

    valid_ids = @sections.map { |s| s[:id] }

    @shared_drop = @paid_media_posts.find_by(id: params[:drop]) if params[:drop].present?
    @referring_user = User.find_by(handle: params[:ref].to_s.downcase.strip) if params[:ref].present?

    if @shared_drop.present?
      @active_tab = "vault"
    elsif valid_ids.include?(requested)
      @active_tab = requested
    elsif @query.present?
      @active_tab = "recommendations"
    else
      # Default to the first tab that has content, so creators with only recommendations
      # or only posts land immediately on their content
      has_content = {
        "posts"           => @creator_posts.any?,
        "recommendations" => @all_links.any?,
        "vault"           => @paid_media_posts.any? || @paid_media_collections.any? || @subscription_plans.any?,
        "wishlist"        => @wishlists.any? { |w| w.wishlist_items.any? },
        "about"           => true
      }
      @active_tab = valid_ids.find { |id| has_content[id] } || "recommendations"
    end
    @social_links = [
      [ "Instagram", @user.instagram_handle, "https://instagram.com/" ],
      [ "YouTube", @user.youtube_handle, "https://youtube.com/@" ],
      [ "X", @user.x_handle, "https://x.com/" ],
      [ "Reddit", @user.reddit_handle, "https://reddit.com/user/" ],
      [ "TikTok", @user.tiktok_handle, "https://tiktok.com/@" ]
    ].select { |link| link[1].present? }
  end
end
