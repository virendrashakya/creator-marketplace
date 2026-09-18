# Imagery for the marketing home page.
#
# Every photo on the landing page resolves through here so there is exactly one
# place to swap stock for real material. When you have shot your own creators
# and products, replace the `src` values below and delete the :credit keys.
# Nothing else in the app needs to change.
#
# Current sources are Unsplash (free for commercial use, attribution not
# required but included below so the provenance of each file is traceable).
# Before launch: download these to public/assets/img/ and serve them locally.
# Hotlinking a third party in production means their outage is your outage,
# and their CDN sees every visitor you have.
module MarketingHelper
  # Fixed photo IDs rather than Unsplash's random endpoint: a landing page that
  # reshuffles its own photography on every request cannot be art directed, and
  # the random endpoint has no cache story.
  MARKETING_IMAGES = {
    # The paid item in the phone mock. Locked behind a price, so it is shown
    # blurred: a scene you would plausibly pay to see the rest of.
    locked_set: {
      src: "https://images.unsplash.com/photo-1601288496920-b6154fe3626a?w=400&q=70&auto=format&fit=crop",
      alt: "",
      credit: "Unsplash / @vishalbansal"
    },
    # Recommendation thumbnails. Product-on-surface shots, not models, because
    # the card is about the object the creator vouched for.
    rec_denim: {
      src: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=200&q=70&auto=format&fit=crop",
      alt: "",
      credit: "Unsplash / @ruthson_zimmerman"
    },
    rec_serum: {
      src: "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=200&q=70&auto=format&fit=crop",
      alt: "",
      credit: "Unsplash / @contentpixie"
    },
    # The proof band. A creator working on a phone, shot from behind or at an
    # angle: this is about the work, and a face staring out of a landing page
    # is the single most template-looking choice available.
    creator_at_work: {
      src: "https://images.unsplash.com/photo-1598554747436-c9293d6a588f?w=900&q=75&auto=format&fit=crop",
      alt: "A creator editing photos on a phone",
      credit: "Unsplash / @mathildelangevin"
    }
  }.freeze

  # Renders a marketing photo. Always emits width/height so the page does not
  # shift while photos load, and lazy-loads everything below the hero.
  def marketing_image(key, width:, height:, eager: false, class_name: nil)
    img = MARKETING_IMAGES.fetch(key)
    image_tag img[:src],
      alt: img[:alt],
      width: width,
      height: height,
      class: class_name,
      loading: eager ? "eager" : "lazy",
      fetchpriority: eager ? "high" : nil,
      decoding: eager ? nil : "async",
      referrerpolicy: "no-referrer"
  end

  # Preconnect for the photo host, so the hero image is not waiting on a fresh
  # TLS handshake. Dropped automatically once images are served locally.
  def marketing_image_host
    host = MARKETING_IMAGES.values.first[:src][%r{\Ahttps://[^/]+}]
    host if host && !host.include?("//#{request.host}")
  end
end
