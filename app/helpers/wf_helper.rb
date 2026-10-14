# Helpers for the dark redesign: icons, avatars, cover images and the Studio
# sidebar. Kept apart from ApplicationHelper so the older light screens are
# untouched.
module WfHelper
  # Stroke icons, lifted from the design files. Inner SVG markup only; the
  # wrapper is added by wf_icon so size and colour are set in one place.
  ICONS = {
    share: '<path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/>',
    gift: '<polyline points="20 12 20 22 4 22 4 12"/><rect x="2" y="7" width="20" height="5"/><line x1="12" y1="22" x2="12" y2="7"/>',
    calendar: '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>',
    grid: '<rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/>',
    stack: '<rect x="7" y="7" width="14" height="14" rx="2"/><path d="M3 17V5a2 2 0 0 1 2-2h12"/>',
    bag: '<path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/>',
    lock: '<rect x="4.5" y="10" width="15" height="11" rx="2.5"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/>',
    shield: '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>',
    link: '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>',
    instagram: '<rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><circle cx="17.5" cy="6.5" r="1" fill="currentColor"/>',
    youtube: '<rect x="2" y="5" width="20" height="14" rx="4"/><polygon points="10 9 15 12 10 15 10 9" fill="currentColor"/>',
    globe: '<circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15 15 0 0 1 4 10 15 15 0 0 1-4 10 15 15 0 0 1-4-10 15 15 0 0 1 4-10z"/>',
    pen: '<path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/>',
    arrow: '<line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/>',
    clock: '<circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15 14"/>',
    image: '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>',
    bell: '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/>',
    chat: '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>',
    users: '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
    video: '<polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2"/>',
    send: '<line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/>',
    alert: '<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>',
    wifi_off: '<line x1="1" y1="1" x2="23" y2="23"/><path d="M16.72 11.06A10.94 10.94 0 0 1 19 12.55"/><path d="M5 12.55a10.94 10.94 0 0 1 5.17-2.39"/><path d="M10.71 5.05A16 16 0 0 1 22.58 9"/><path d="M1.42 9a15.91 15.91 0 0 1 4.7-2.88"/><path d="M8.53 16.11a6 6 0 0 1 6.95 0"/><line x1="12" y1="20" x2="12.01" y2="20"/>',
    sign_out: '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>',
    back: '<polyline points="15 18 9 12 15 6"/>',
    close: '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>',
    upload: '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/>',
    download: '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>',
    trash: '<polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/>',
    eye: '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>'
  }.freeze

  ICONS_THEME = {
    sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/>',
    moon: '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>',
    monitor: '<rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/>'
  }.freeze

  # Filled glyphs, which read better solid at small sizes.
  FILLED = {
    play: '<polygon points="7 4 19 12 7 20 7 4"/>',
    check: '<path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>',
    pin: '<path d="M16 3l5 5-3 1-4 4 1 5-2 2-4-4-5 5-1-1 5-5-4-4 2-2 5 1 4-4z"/>',
    grip: '<circle cx="9" cy="6" r="1.6"/><circle cx="15" cy="6" r="1.6"/><circle cx="9" cy="12" r="1.6"/><circle cx="15" cy="12" r="1.6"/><circle cx="9" cy="18" r="1.6"/><circle cx="15" cy="18" r="1.6"/>'
  }.freeze

  def wf_icon(name, size: nil, stroke: 2, css: nil, color: nil)
    name = name.to_sym
    style = []
    style << "font-size:#{size}px" if size
    style << "color:#{color}" if color
    attrs = { class: [ "w-icon", css ].compact.join(" "), viewBox: "0 0 24 24", "aria-hidden": "true", focusable: "false" }
    attrs[:style] = style.join(";") if style.any?

    if FILLED.key?(name)
      content_tag(:svg, FILLED[name].html_safe, attrs.merge(fill: "currentColor"))
    else
      content_tag(:svg, (ICONS[name] || ICONS_THEME.fetch(name)).html_safe,
                  attrs.merge(fill: "none", stroke: "currentColor", "stroke-width": stroke,
                              "stroke-linecap": "round", "stroke-linejoin": "round"))
    end
  end

  # The pink verified disc next to a creator's handle. Every creator on
  # Wishful has verified a UPI ID, which is what this tick means.
  def wf_verified(size: 16)
    content_tag(:svg, %(<circle cx="12" cy="12" r="10" fill="#E0306A"/><path d="M8 12.5l2.5 2.5 5.5-6" fill="none" stroke="#FFFFFF" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>).html_safe,
                viewBox: "0 0 24 24", width: size, height: size, class: "w-verified", role: "img", "aria-label": "Verified creator")
  end

  def wf_social_icon(key)
    case key.to_s
    when "instagram" then wf_icon(:instagram)
    when "youtube" then wf_icon(:youtube)
    when "blog" then wf_icon(:pen)
    when "x" then content_tag(:span, "𝕏", style: "font-size:12px;font-weight:800;line-height:1", "aria-hidden": "true")
    else wf_icon(:globe)
    end
  end

  # A person's picture, or their initial on a dark disc when they have none.
  def wf_avatar(user, size: 32, css: nil)
    src = wf_avatar_src(user)
    if src
      image_tag src, alt: "", width: size, height: size, class: [ "w-avatar", css ].compact.join(" "),
                     style: "width:#{size}px;height:#{size}px", loading: "lazy"
    else
      content_tag(:span, user&.name.to_s.first.to_s.upcase.presence || "?",
                  class: [ "w-initial", css ].compact.join(" "),
                  style: "width:#{size}px;height:#{size}px;font-size:#{(size * 0.38).round}px", "aria-hidden": "true")
    end
  end

  def wf_avatar_src(user)
    return nil if user.blank?
    return url_for(user.profile_picture) if user.profile_picture.attached?

    user.avatar_url.presence
  end

  def wf_banner_src(user)
    return url_for(user.banner) if user.banner.attached?

    wf_avatar_src(user)
  end

  # The public image for a collection. The editor tells the creator, in so
  # many words, that the first item is the public cover, so it is served
  # unblurred to everyone (through the media endpoint, which allows covers).
  # A video cover shows its preview frame instead.
  def wf_collection_cover_src(collection)
    post = collection.cover_post
    return nil unless post
    return media_paid_media_post_path(post) if post.media_type == "image"

    post.preview.attached? ? url_for(post.preview) : preview_paid_media_post_path(post)
  end

  def wf_post_image_src(post, viewer_can_see: post.unlocked_for?(current_user))
    if post.preview.attached?
      url_for(post.preview)
    elsif viewer_can_see && post.media_type == "image"
      media_paid_media_post_path(post)
    else
      preview_paid_media_post_path(post)
    end
  end

  def wf_creator_post_src(post)
    post.media.attached? ? url_for(post.media) : nil
  end

  # What a fan is paying for, in the shape the pay sheet and receipts need:
  # an image, a title and a line of detail.
  def wf_purchase_summary(item)
    creator = item.is_a?(MeetSlot) ? item.meet_offer.user : (item.try(:user) || item.try(:wishlist)&.user)
    case item
    when PaidMediaCollection
      { image: wf_collection_cover_src(item), title: item.title, meta: "#{item.contents_label} · by #{creator.name}" }
    when PaidMediaPost
      { image: wf_post_image_src(item), title: item.title, meta: "1 #{item.media_type == "video" ? "reel" : "photo"} · by #{creator.name}" }
    when SubscriptionPlan
      { image: wf_avatar_src(creator), title: "Close Friends", meta: "#{item.name} · one month · by #{creator.name}" }
    when MeetSlot
      { image: wf_avatar_src(creator), title: item.meet_offer.title,
        meta: "#{item.starts_at.strftime("%a %-d %b")}, #{wf_time(item.starts_at)} · #{item.meet_offer.duration_minutes} min" }
    when WishlistItem
      { image: item.image_url.presence || wf_banner_src(creator), title: item.title, meta: "A gift for #{creator.name}" }
    when ContactReveal
      { image: wf_avatar_src(creator), title: item.label, meta: "Private access · by #{creator.name}" }
    else
      { image: wf_avatar_src(creator), title: item.try(:title).to_s, meta: creator&.name.to_s }
    end.merge(creator: creator)
  end

  # Studio sidebar. Badge counts come from the controller-agnostic
  # wf_studio_counts so every Studio page shows the same numbers.
  def wf_studio_nav
    counts = wf_studio_counts
    [
      [ "Overview", dashboard_path, %w[dashboard] ],
      [ "Posts", creator_posts_path, %w[creator_posts] ],
      [ "Collections", paid_media_collections_path, %w[paid_media_collections paid_media_posts] ],
      [ "Shop", product_links_path, %w[product_links collections] ],
      [ "Link lists", link_lists_path, %w[link_lists], { new: true } ],
      [ "Book", schedule_path, %w[schedule meet_offers live_sessions] ],
      [ "Payments", payment_claims_path, %w[payment_claims], { count: counts[:claims], pink: true } ],
      [ "Messages", conversations_path, %w[conversations], { count: counts[:unread] } ],
      [ "Settings", creator_settings_path, %w[creator_settings subscription_plans creator_blocks contact_reveals wishlists wishlist_items] ]
    ]
  end

  def wf_studio_counts
    @wf_studio_counts ||= {
      claims: current_user.received_payment_claims.pending.count,
      unread: Conversation.where(creator_id: current_user.id).sum(:creator_unread_count)
    }
  end

  def wf_nav_current?(controllers)
    controllers.include?(controller_name)
  end

  # The viewer's saved preference: dark (the default), light, or system.
  def wf_theme_pref
    cookies[:wf_theme].presence_in(ThemesController::THEMES) || "dark"
  end

  # "2h ago", "40m ago", "Sun" — the way the design writes times.
  def wf_ago(time)
    return "" if time.blank?

    seconds = Time.current - time
    if seconds < 60 then "now"
    elsif seconds < 3600 then "#{(seconds / 60).floor}m ago"
    elsif seconds < 86_400 then "#{(seconds / 3600).floor}h ago"
    elsif seconds < 7 * 86_400 then time.strftime("%a")
    else time.strftime("%-d %b")
    end
  end

  # 18400 -> "18.4k", the way follower counts are read.
  def wf_compact(number)
    n = number.to_i
    return n.to_s if n < 1000
    return "#{(n / 1000.0).round(1).to_s.delete_suffix(".0")}k" if n < 1_000_000

    "#{(n / 1_000_000.0).round(1).to_s.delete_suffix(".0")}M"
  end

  def wf_time(time)
    time.strftime("%-l:%M %p")
  end

  # A smooth line and its filled area for a 600x120 chart. Catmull-Rom
  # through the points, converted to cubic Béziers, so a sparse series still
  # reads as a curve rather than a staircase.
  def wf_chart_paths(values, width: 600, height: 120, pad: 10)
    values = [ 0, 0 ] if values.size < 2
    max = [ values.max.to_f, 1.0 ].max
    step = width.to_f / (values.size - 1)
    pts = values.each_with_index.map { |v, i| [ (i * step).round(1), (height - pad - (v / max) * (height - pad * 2)).round(1) ] }
    d = +"M#{pts[0][0]} #{pts[0][1]}"
    pts.each_cons(2).with_index do |(p1, p2), i|
      p0 = i.zero? ? p1 : pts[i - 1]
      p3 = pts[i + 2] || p2
      c1 = [ p1[0] + (p2[0] - p0[0]) / 6.0, p1[1] + (p2[1] - p0[1]) / 6.0 ]
      c2 = [ p2[0] - (p3[0] - p1[0]) / 6.0, p2[1] - (p3[1] - p1[1]) / 6.0 ]
      d << " C#{c1[0].round(1)} #{c1[1].round(1)}, #{c2[0].round(1)} #{c2[1].round(1)}, #{p2[0]} #{p2[1]}"
    end
    [ d, "#{d} L#{width} #{height} L0 #{height} Z" ]
  end

  # Inline SVG QR code. Used for a creator's UPI ID and for link lists.
  def wf_qr_svg(text, size: 200)
    qr = RQRCode::QRCode.new(text.to_s)
    qr.as_svg(module_size: 4, standalone: true, use_path: true, viewbox: true,
              svg_attributes: { width: size, height: size, role: "img", "aria-label": "QR code" }).html_safe
  end

  # The hash string for a watermark overlay: "@meera.k · ID 48213".
  def wf_watermark_line(user)
    mark = "@#{user.handle} · ID #{user.id}"
    ([ mark ] * 3).join(" · ")
  end
end
