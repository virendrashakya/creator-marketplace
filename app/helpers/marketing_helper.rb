# Imagery for the marketing home page.
#
# Every photo resolves through here, so there is exactly one place to swap
# stock for your own material. When you have shot real creators and products,
# drop the files into public/assets/img/ under the same keys and delete the
# :credit lines. No view needs to change.
#
# Files are served from public/assets/img rather than hotlinked from a photo
# CDN on purpose: hotlinking makes a third party's outage your outage, and
# hands them the IP of every visitor you have.
#
# Provenance: Unsplash, which grants free commercial use without attribution.
# Credits are recorded anyway so each file can be traced back before launch.
# CHECK BEFORE LAUNCH: photos of identifiable people carry no model release
# from Unsplash. The two portraits below are illustrative placeholders. Replace
# them with creators who have signed a release, or with your own shoots.
module MarketingHelper
  MARKETING_IMAGES = {
    # Hero: a real creator page belongs to a real-looking person. Indian
    # creator, saree, deep red ground that sits with the marigold/pink accent
    # rather than fighting it.
    creator_hero: {
      file: "creator-saree.jpg", w: 560, h: 840,
      alt: "A creator photographed against a deep red backdrop",
      credit: "Unsplash"
    },
    # The paid item in the phone mock, shown blurred because it is locked.
    creator_locked: {
      file: "creator-portrait.jpg", w: 800, h: 1000,
      alt: "",
      credit: "Unsplash"
    },
    # Phone-first is the whole constraint of this product, so show a phone
    # being held, not a floating device render.
    phone_in_hand: {
      file: "phone-in-hand.jpg", w: 400, h: 600,
      alt: "A phone held up in one hand",
      credit: "Unsplash"
    },
    # Recommendation thumbnails: the object the creator vouched for, not a
    # model wearing it. A recommendation is about the thing.
    rec_denim:  { file: "rec-denim.jpg",  w: 240, h: 192, alt: "", credit: "Unsplash" },
    rec_serum:  { file: "rec-serum.jpg",  w: 240, h: 360, alt: "", credit: "Unsplash" },
    rec_camera: { file: "rec-camera.jpg", w: 1000, h: 667, alt: "", credit: "Unsplash" }
  }.freeze

  # Renders a marketing photo at an explicit intrinsic size so the page never
  # shifts while photos load. Only the hero image is eager; everything below
  # the fold waits.
  def marketing_image(key, eager: false, class_name: nil, sizes: nil)
    img = MARKETING_IMAGES.fetch(key)
    image_tag "/assets/img/#{img[:file]}",
      alt: img[:alt],
      width: img[:w],
      height: img[:h],
      sizes: sizes,
      class: class_name,
      loading: eager ? "eager" : "lazy",
      fetchpriority: eager ? "high" : nil,
      decoding: eager ? "sync" : "async"
  end

  # The aspect ratio of a marketing photo, for reserving space in CSS.
  def marketing_ratio(key)
    img = MARKETING_IMAGES.fetch(key)
    "#{img[:w]} / #{img[:h]}"
  end
end
