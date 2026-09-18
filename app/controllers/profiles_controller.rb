class ProfilesController < ApplicationController
  # Below this many recommendations, search and category chips are noise.
  # Wishlink's creators have thousands of items and need both; a creator with
  # twelve links does not.
  FILTER_THRESHOLD = 12

  def show
    @user = User.find_by!(handle: params[:handle])
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
    @sections = [
      ({ id: "posts",   label: "Posts",   icon: "post"   } if @creator_posts.any?),
      ({ id: "unlock",  label: "Unlock",  icon: "lock"   } if @paid_media_posts.any?),
      ({ id: "shop",    label: "Shop",    icon: "shop"   } if @all_links.any?),
      ({ id: "time",    label: "Book",    icon: "clock"  } if @meet_offers.any? || @contact_reveals.any?),
      ({ id: "gifts",   label: "Gifts",   icon: "gift"   } if @wishlists.any? { |w| w.wishlist_items.any? })
    ].compact

    # One section at a time. Anchor links only moved the reader around a page
    # that was already too long; with 13 recommendations plus posts, media,
    # slots and gifts the scroll was the problem, not the navigation.
    #
    # ?tab= is a real URL so a creator can put /@handle?tab=shop straight in a
    # story, and back/forward and refresh all behave. An unknown or missing
    # value falls back to the first section that has content rather than
    # 404ing: a stale shared link should still land somewhere useful.
    ids = @sections.map { |s| s[:id] }
    requested = params[:tab].to_s
    @active_tab = ids.include?(requested) ? requested : ids.first

    # A search only makes sense inside the shop, and arriving with ?q= should
    # take you there rather than showing a result count on the posts tab.
    @active_tab = "shop" if @query.present? && ids.include?("shop")
    @social_links = [
      [ "Instagram", @user.instagram_handle, "https://instagram.com/" ],
      [ "YouTube", @user.youtube_handle, "https://youtube.com/@" ],
      [ "X", @user.x_handle, "https://x.com/" ],
      [ "Reddit", @user.reddit_handle, "https://reddit.com/user/" ],
      [ "TikTok", @user.tiktok_handle, "https://tiktok.com/@" ]
    ].select { |link| link[1].present? }
  end
end
