# Seeds for development. Idempotent: safe to run repeatedly.
#
# The point of this file is a *bold* flagship creator. A demo account with two
# links and no imagery makes the product look like a form, not a page, so
# @ananyarao below is filled out the way a real creator would fill it out:
# every section populated, prices in paise, a payment queue with something
# actually waiting in it, and one deliberate amount mismatch so the review
# screen's warning state is visible without anyone having to fake data by hand.
#
# Run with:  bin/rails db:seed
#
# Photos come from public/assets/img (see MarketingHelper for provenance).
# Passwords are all "password123" in development.

PASSWORD = "password123".freeze
IMG = Rails.root.join("public/assets/img")

# ProductLink has no attachment; it stores a remote image_url and validates
# that it is a public http(s) URL. These are the same Unsplash sources the
# local files in public/assets/img were taken from, so seeded cards show the
# same pictures the marketing page does. Swap for your own CDN when you have
# one.
REMOTE_IMAGES = {
  "rec-denim.jpg"       => "https://images.unsplash.com/photo-1542272604-787c3835535d?w=240&q=72&auto=format&fit=crop",
  "rec-serum.jpg"       => "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=240&q=72&auto=format&fit=crop",
  "rec-camera.jpg"      => "https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400&q=72&auto=format&fit=crop",
  "rec-saree-chiffon"   => "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=400&q=75&auto=format&fit=crop",
  "rec-saree-silk"      => "https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=400&q=75&auto=format&fit=crop",
  "rec-jewelry"         => "https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400&q=75&auto=format&fit=crop"
}.freeze

def attach_image(record, attachment, filename)
  path = IMG.join(filename)
  return unless File.exist?(path)
  # Re-attaching on every seed run would pile up blobs.
  return if record.public_send(attachment).attached?

  # basename, not the passed path: filenames like "creators/c1.jpg" would put
  # a slash in the stored blob filename.
  record.public_send(attachment).attach(
    io: File.open(path), filename: File.basename(filename), content_type: "image/jpeg"
  )
end

def upsert_user!(email, attrs)
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(attrs.merge(password: PASSWORD, password_confirmation: PASSWORD))
  user.save!
  user
end

puts "Seeding…"

# ---------------------------------------------------------------------------
# The flagship: a fashion and lifestyle creator in Mumbai, fully set up.
# ---------------------------------------------------------------------------

ananya = upsert_user!(
  "ananya@example.com",
  name: "Ananya Rao",
  handle: "ananyarao",
  bio: "32 | Mumbai. Saree draper, editorial model & GRWM reels creator. " \
       "Celebrating heritage handloom silks, bold modern cuts & effortless drapes. " \
       "Exclusive 4K lookbooks, blouse design guides & uncut fitting BTS in the Vault. ✨",
  pronouns: "she/her",
  location: "Mumbai, India",
  creator_category: "Fashion",
  creator_subcategory: "Saree Drapes & GRWM",
  theme: "minimal",
  profile_layout: "editorial",
  account_type: "creator",
  instagram_handle: "ananyarao",
  youtube_handle: "ananyarao",
  x_handle: "ananyarao",
  website_url: "https://ananyarao.example.com",
  public_email: "hello@ananyarao.example.com",
  # Paise-denominated prices everywhere, and a UPI ID that matches the
  # yourname@bank format the model enforces.
  upi_id: "ananyarao@okaxis",
  upi_payee_name: "Ananya Rao",
  accepts_upi_manual: true,
  date_of_birth: Date.new(1994, 7, 18),
  links_heading: "My Saree Wardrobe & Go-To Fits",
  media_heading: "The Vault: 4K Saree Lookbooks & BTS",
  meet_heading: "1:1 Drape Masterclass & Styling",
  reveal_heading: "VIP Close Friends (Direct Access)"
)
attach_image(ananya, :profile_picture, "creator-portrait.jpg")
attach_image(ananya, :banner, "creator-saree.jpg")

# --- collections and recommendations ---------------------------------------
# Each reason is a sentence a person would actually say. The card leads with
# the reason, so a recommendation without one renders as a bare product name.

collections = {
  "Ananya's Curated Fit Picks" => [
    [ "Pre-Stitched Ruffled Saree", "Myntra", "₹2,799", "rec-saree-chiffon",
      "Deep Burgundy Drape", true ],
    [ "Handcrafted Kamarbandh", "FabIndia", "₹2,850", "rec-jewelry",
      "Pure Silver 925", true ],
    [ "Halter Neck Brocade Blouse", "Nykaa Fashion", "₹1,699", "rec-saree-silk",
      "Golden Zari Weave", true ],
    [ "Velvet Drape Corset Top", "Amazon Fashion", "₹1,499", "rec-denim.jpg",
      "Plum Structure", true ]
  ],
  "My Saree Wardrobe & Go-To Drapes" => [
    [ "Pure Chiffon Saree with Sequin Border", "Swtantra", "₹3,499", "rec-saree-chiffon",
      "Drapes like liquid glass. The exact piece from my monsoon balcony reel that crossed a million views.", true ],
    [ "Raw Silk Backless Blouse", "Nykaa Fashion", "₹1,899", nil,
      "Structured fit, deep cut, and padded so you never have to wrestle with tape or visible straps." ],
    [ "Saree Shapewear Mermaid Skirt", "Zivame", "₹1,299", nil,
      "The secret to clean pleats and a structured fall. I will never go back to drawstring cotton petticoats." ]
  ],
  "GRWM Essentials & Skin Prep" => [
    [ "Hydrating Dewy Primer Serum", "Nykaa", "₹649", "rec-serum.jpg",
      "Skin prep before six hours under studio lights. Keeps heavy ethnic makeup from creasing." ],
    [ "Matte Velvet Lip Stain, Brick Red", "Nykaa", "₹450", nil,
      "The classic wedding guest red that doesn't bleed onto collarbones or cups." ],
    [ "Setting Spray that Survives Humidity", "Nykaa", "₹550", nil,
      "Tested through 35°C outdoor shoots in Bombay. My base did not budge until midnight." ]
  ]
}

collections.each do |name, items|
  collection = ananya.link_collections.find_or_create_by!(name: name)
  items.each do |title, merchant, price, image, reason, featured|
    link = ananya.product_links.find_or_initialize_by(title: title)
    link.assign_attributes(
      url: "https://example.com/#{title.parameterize}",
      merchant: merchant,
      price: price,
      description: reason,
      link_collection: collection,
      featured: featured.present?
    )
    link.image_url = REMOTE_IMAGES[image] if image
    link.save!
  end
end

# --- paid media ------------------------------------------------------------
# The differentiator: the creator's own work behind a one-time unlock.

[
  [ "Golden Hour in Goa (Uncensored 4K Set)", "Full sunset sequence, wet silk drape experiment & unreleased BTS clips.", 49_900, "creator-saree.jpg" ],
  [ "Festive Silk Drapes & Backless Blouse BTS", "Archival Mumbai studio shoot. High dynamic range color grades focusing on handloom Banarasi motifs and uncut fitting room clips.", 29_900, "creator-portrait.jpg" ],
  [ "Private Reels & Unreleased Outfit Haul", "Candid GRWM commentary, drape hacks & bloopers not on IG.", 19_900, "creator-saree.jpg" ]
].each do |title, caption, price_cents, preview|
  post = ananya.paid_media_posts.find_or_initialize_by(title: title)
  post.assign_attributes(
    caption: caption, price_cents: price_cents, currency: "INR",
    media_type: (title.include?("Reels") || title.include?("Video") ? "video" : "image"), published: true
  )
  attach_image(post, :media, preview)
  attach_image(post, :preview, preview)
  post.save!
end

# --- a meetup with real, future slots --------------------------------------

meet = ananya.meet_offers.find_or_initialize_by(title: "1:1 Saree Drape & Styling Masterclass (30 mins)")
meet.assign_attributes(
  description: "Face-to-face private video call. Master flawless pleating, blouse neckline selection, saree shapewear, or creator posing for 4K reels.",
  location: "Private Video Call (1:1)",
  duration_minutes: 30,
  price_cents: 149_900,
  currency: "INR",
  published: true
)
meet.save!

# Slots must be real future dates or they never render as bookable.
[ 3, 5, 5, 9 ].each_with_index do |days, i|
  start = (Time.zone.now + days.days).change(hour: 11 + (i % 3) * 2, min: 0)
  next if meet.meet_slots.exists?(starts_at: start)
  meet.meet_slots.create!(starts_at: start, ends_at: start + meet.duration_minutes.minutes)
end

# --- contact reveal --------------------------------------------------------

reveal = ananya.contact_reveals.find_or_initialize_by(label: "Private Close Friends VIP WhatsApp (Direct DMs & Daily Stories)")
reveal.assign_attributes(
  secret_value: "+91 98200 44921", price_cents: 99_900, currency: "INR", published: true
)
reveal.save!

# --- gift wishlist ---------------------------------------------------------
# Deliberately spread across funding states so the progress meter shows
# empty, partial and funded on one page.

studio = ananya.wishlists.find_or_initialize_by(title: "Spoil Me & Shoot Wardrobe ✨")
studio.assign_attributes(
  description: "Help fund pieces for upcoming festive lookbooks, bespoke blouses and 4K Vault reel productions.",
  published: true
)
studio.save!

[
  [ "Banarasi Katan Silk Saree in Emerald", 24_500_00, "For the upcoming royal heritage lookbook in Jaipur." ],
  [ "Dyson Airwrap Multi-Styler", 45_900_00, "For quick voluminous waves between GRWM changes." ],
  [ "Heritage Temple Jewelry Choker Set", 16_000_00, "Handcrafted antique gold finish for bridal drape shoots." ]
].each do |title, target_cents, note|
  item = studio.wishlist_items.find_or_initialize_by(title: title)
  item.assign_attributes(target_cents: target_cents, currency: "INR", note: note)
  item.save!
end

# --- subscription plan -----------------------------------------------------

plan = ananya.subscription_plans.find_or_initialize_by(name: "Close Friends All-Access VIP")
plan.assign_attributes(
  description: "Automatic unlock for all current & future Vault drops, daily private stories, and priority replies in 1:1 chat.",
  price_cents: 49_900, currency: "INR", active: true
)
plan.save!

# --- posts -----------------------------------------------------------------

[
  "Just wrapped the golden hour chiffon saree shoot on the terrace! Editing the 4K slow-mo reel set now — drops in the Vault tonight! 🔥",
  "GRWM poll: Pairing this royal blue organza saree with a halter blouse or high-neck brocade for tonight's event? Let me know in comments! 💫",
  "Uploaded the uncut 12-minute drape & blouse fitting video for Close Friends VIP members. Check your Vault access! 💖"
].each_with_index do |body, i|
  post = ananya.creator_posts.find_or_initialize_by(body: body)
  post.published = true
  post.save!
  attach_image(post, :media, "creator-saree.jpg") if i.zero?
end

puts "  @#{ananya.handle}: #{ananya.product_links.count} links, " \
     "#{ananya.paid_media_posts.count} paid media, " \
     "#{studio.wishlist_items.count} gifts, #{ananya.creator_posts.count} posts"

# ---------------------------------------------------------------------------
# Two more creators, so the themes and layouts are all visible somewhere and
# the flagship is not the only page that exists.
# ---------------------------------------------------------------------------

raya = upsert_user!(
  "raya@example.com",
  name: "Raya Menon",
  handle: "rayamakes",
  bio: "Ceramics, mostly. Everything here is made by hand in Fort Kochi.",
  pronouns: "they/them",
  location: "Kochi, India",
  creator_category: "Art & design",
  creator_subcategory: "Ceramics",
  theme: "luxury",
  profile_layout: "gallery",
  account_type: "creator",
  instagram_handle: "rayamakes",
  upi_id: "rayamenon@okhdfcbank",
  upi_payee_name: "Raya Menon",
  accepts_upi_manual: true
)

pottery = raya.link_collections.find_or_create_by!(name: "Tools I use")
[
  [ "The wheel I learned on", "Amazon", "₹18,500",
    "Second hand, still going after four years and about two hundred pots." ],
  [ "Trimming tools, cheap set", "Amazon", "₹640",
    "You do not need the expensive ones until you know what you are doing." ]
].each do |title, merchant, price, reason|
  link = raya.product_links.find_or_initialize_by(title: title)
  link.assign_attributes(url: "https://example.com/#{title.parameterize}",
    merchant: merchant, price: price, description: reason, link_collection: pottery)
  link.save!
end

kiln = raya.wishlists.find_or_initialize_by(title: "Kiln fund")
kiln.assign_attributes(description: "Mine cracked in June. This is the replacement.", published: true)
kiln.save!
item = kiln.wishlist_items.find_or_initialize_by(title: "Top-loading kiln")
item.assign_attributes(target_cents: 85_000_00, currency: "INR",
  note: "The one thing standing between me and firing again.")
item.save!

dev = upsert_user!(
  "dev@example.com",
  name: "Dev Sharma",
  handle: "devsharma",
  bio: "Trek notes, gear that survived, and the routes nobody posts about.",
  location: "Manali, India",
  creator_category: "Travel",
  theme: "adventure",
  profile_layout: "classic",
  account_type: "creator",
  instagram_handle: "devsharma",
  upi_id: "devsharma@oksbi",
  upi_payee_name: "Dev Sharma",
  accepts_upi_manual: true
)

gear = dev.link_collections.find_or_create_by!(name: "Gear that survived")
[
  [ "Boots, 900km in", "Decathlon", "₹4,999",
    "Two seasons, one resole, still dry inside. Buy a size up." ],
  [ "The 30L pack", "Decathlon", "₹2,799",
    "Everything I take for three days fits in this and nothing else." ]
].each do |title, merchant, price, reason|
  link = dev.product_links.find_or_initialize_by(title: title)
  link.assign_attributes(url: "https://example.com/#{title.parameterize}",
    merchant: merchant, price: price, description: reason, link_collection: gear)
  link.save!
end

# ---------------------------------------------------------------------------
# Fans. They exist to make follower counts, likes, comments and the payment
# queue real rather than zeroed out.
# ---------------------------------------------------------------------------

fans = [
  [ "priya@example.com",  "Priya Nair",    "priyanair" ],
  [ "aditi@example.com",  "Aditi Joshi",   "aditijoshi" ],
  [ "kabir@example.com",  "Kabir Anand",   "kabiranand" ],
  [ "sana@example.com",   "Sana Qureshi",  "sanaq" ],
  [ "rohit@example.com",  "Rohit Verma",   "rohitverma" ]
].map { |email, name, handle| upsert_user!(email, name: name, handle: handle, account_type: "personal") }

# Follows. Ananya is the flagship, so she gets the most.
fans.each { |fan| CreatorFollow.find_or_create_by!(creator: ananya, follower: fan) }
fans.first(3).each { |fan| CreatorFollow.find_or_create_by!(creator: raya, follower: fan) }
fans.first(2).each { |fan| CreatorFollow.find_or_create_by!(creator: dev, follower: fan) }
[ raya, dev ].each { |c| CreatorFollow.find_or_create_by!(creator: ananya, follower: c) }

# Likes and comments on the newest post, so the social row is not all zeros.
latest = ananya.creator_posts.order(created_at: :desc).first
if latest
  fans.first(4).each { |fan| CreatorPostLike.find_or_create_by!(creator_post: latest, user: fan) }
  [
    [ fans[0], "The blue one please. Been waiting for this set." ],
    [ fans[2], "How much for just the edited ones?" ]
  ].each do |fan, body|
    CreatorPostComment.find_or_create_by!(creator_post: latest, user: fan, body: body)
  end
end

# Partial gift contributions, so the wishlist meters show three different
# states on one page: nothing yet, part-funded, and fully funded.
lens    = studio.wishlist_items.find_by(title: "35mm lens")
softbox = studio.wishlist_items.find_by(title: "Proper softbox")
stand   = studio.wishlist_items.find_by(title: "Backdrop stand")

def contribute!(item, giver, amount_cents, message = nil)
  return if item.blank?
  return if GiftContribution.exists?(wishlist_item: item, giver: giver)

  # status must be "paid": raised_cents sums only paid contributions, so a
  # pending one leaves every progress meter reading zero.
  GiftContribution.create!(wishlist_item: item, giver: giver,
    amount_cents: amount_cents, message: message, status: "paid")
end

# Lens: part way there.
contribute!(lens, fans[0], 8_000_00, "For the studio. Long overdue.")
contribute!(lens, fans[1], 5_500_00)
contribute!(lens, fans[3], 2_000_00, "Small but from the heart")
# Softbox: fully funded, so the "funded" state renders.
contribute!(softbox, fans[2], 12_000_00, "Go shoot something good")
# Backdrop stand: deliberately left at zero for the empty meter.

# ---------------------------------------------------------------------------
# The payment queue. This is the screen that most needed real data: it has a
# warning state for when the amount a fan claims to have sent differs from
# the amount due, and that state is invisible without a mismatched claim.
# ---------------------------------------------------------------------------

goa   = ananya.paid_media_posts.find_by(title: "Monsoon Balcony in Chiffon (4K Saree Lookbook, 42 photos)") || ananya.paid_media_posts.first
edit  = ananya.paid_media_posts.find_by(title: "GRWM: Festive Silk Fitting & Blouse BTS (4K Video, 12 mins)") || ananya.paid_media_posts.last
slot  = meet.meet_slots.order(:starts_at).first

def claim!(creator:, claimant:, purchasable:, amount_cents:, utr:, status: "pending",
           claimed_amount_cents: nil, note: nil, reviewed_by: nil, reject_reason: nil)
  return nil if purchasable.blank?
  # Returns nil when the claim already exists, so callers must use &. before
  # approve!/reject! on a repeat seed run.
  return nil if PaymentClaim.exists?(utr: utr)

  PaymentClaim.create!(
    creator: creator, claimant: claimant, purchasable: purchasable,
    amount_cents: amount_cents, claimed_amount_cents: claimed_amount_cents || amount_cents,
    currency: "INR", payment_method: "upi_manual", utr: utr, note: note,
    status: status,
    reviewed_at: (Time.zone.now - 2.hours if status != "pending"),
    reviewed_by: (reviewed_by if status != "pending"),
    reject_reason: reject_reason
  )
end

# Waiting for review.
claim!(creator: ananya, claimant: fans[0], purchasable: goa,
       amount_cents: 49_900, utr: "402913887561",
       note: "Paid from GPay just now, sorry the screenshot is blurry")

# The important one: claims to have sent less than the amount due, so the
# review screen's mismatch warning is visible in development.
claim!(creator: ananya, claimant: fans[1], purchasable: edit,
       amount_cents: 29_900, claimed_amount_cents: 19_900, utr: "556120449031",
       note: "Sent 199, hope that is ok")

# And one over-payment, the other direction of the same warning.
claim!(creator: ananya, claimant: fans[3], purchasable: goa,
       amount_cents: 49_900, claimed_amount_cents: 50_000, utr: "778345120094",
       note: "Rounded up, keep the change")

claim!(creator: ananya, claimant: fans[4], purchasable: slot,
       amount_cents: meet.price_cents, utr: "219087554310",
       note: "Booking the Saturday slot") if slot

# Already decided, for the "recently reviewed" list.
#
# Approve through the model rather than writing the status directly:
# PaymentClaim#approve! runs PaymentFulfillment#grant!, which is what actually
# creates the MediaPurchase. Inserting status: "approved" by hand leaves the
# buyer without access and the dashboard revenue stat reading zero next to an
# approved payment.
approved = claim!(creator: ananya, claimant: fans[2], purchasable: edit,
                  amount_cents: 29_900, utr: "664201889737")
approved&.approve!(ananya)

rejected = claim!(creator: ananya, claimant: fans[2], purchasable: goa,
                  amount_cents: 49_900, utr: "110458332901")
rejected&.reject!(ananya, "No matching credit on the statement for this reference.")

# Link clicks, so the dashboard's referral stat is not a zero. Recorded as
# LinkClick rows because clicks_count is a counter cache over that table.
#
# Ordered by id, not by the model's default_scope: that scope sorts by
# featured/position/created_at, so the same link landed at a different index
# on each run and the click totals crept upward instead of settling.
CLICK_TARGETS = [ 41, 28, 17, 12, 9, 7, 5, 4, 3, 2, 2, 1, 1 ].freeze

ananya.product_links.reorder(:id).each_with_index do |link, i|
  target = CLICK_TARGETS[i] || 1
  missing = target - link.link_clicks.count
  next if missing <= 0

  missing.times do |n|
    link.link_clicks.create!(
      referrer: [ "https://instagram.com/", "https://youtube.com/", nil ][n % 3],
      created_at: Time.zone.now - (n % 30).days
    )
  end
end

# ---------------------------------------------------------------------------
# The October redesign: phone sign-in, collections, link lists.
# ---------------------------------------------------------------------------

# Phone numbers, so the WhatsApp OTP sign-in can be tried in development (the
# code is printed in the log and flashed on screen when no provider is set).
ananya.update!(phone_number: "+ ", phone_verified_at: Time.current, onboarded_at: Time.current,
               blog_url: "https://ananyarao.example.com/blog", upi_payee_name: "ANANYA RAO",
               accepts_upi_manual: true)
fans[0].update!(phone_number: "+919876543210", phone_verified_at: Time.current, notify_whatsapp_claims: true)

cf_plan = ananya.subscription_plans.where(active: true).order(:price_cents).first

COLLECTION_IMAGES = %w[
  creator-saree.jpg creator-portrait.jpg creators/c3.jpg creators/c7.jpg creators/c11.jpg
  creators/c15.jpg creators/c19.jpg creators/c23.jpg creators/c27.jpg creators/c31.jpg
].freeze

def seed_collection!(creator, title:, description:, price_cents:, items:, offset:, plan: nil, published: true, release_at: nil)
  collection = creator.paid_media_collections.find_or_initialize_by(title: title)
  collection.assign_attributes(description: description, price_cents: price_cents, currency: "INR",
                               subscription_plan: plan, published: published, release_at: release_at)
  collection.save!
  items.times do |i|
    post = collection.paid_media_posts.find_or_initialize_by(user: creator, position: i)
    post.assign_attributes(title: "#{title} · #{i + 1}", media_type: "image", currency: "INR", published: true)
    attach_image(post, :media, COLLECTION_IMAGES[(offset + i) % COLLECTION_IMAGES.size])
    post.save!
  end
  collection
end

goa_set = seed_collection!(ananya, title: "Golden Hour in Goa", offset: 0, items: 8, plan: cf_plan, price_cents: 49_900,
  description: "Full sunset sequence, a wet silk drape experiment and unreleased BTS stills.")
festive = seed_collection!(ananya, title: "Festive Silk BTS", offset: 1, items: 6, price_cents: 29_900,
  description: "Archival Mumbai studio shoot. Handloom Banarasi motifs and fitting-room moments.")
banarasi = seed_collection!(ananya, title: "Banarasi Heritage", offset: 4, items: 6, plan: cf_plan, price_cents: 29_900,
  description: "Three drapes, one heirloom saree, natural light.")
seed_collection!(ananya, title: "Diwali shoot", offset: 6, items: 6, plan: cf_plan, price_cents: 49_900,
  description: "Temple-border silk, three drapes, golden-hour light.", release_at: Date.current.next_occurring(:monday).in_time_zone.change(hour: 19))

# A free post that teases a collection.
teaser = ananya.creator_posts.order(created_at: :desc).first
teaser&.update!(paid_media_collection: goa_set)

# Link lists, each with real items and plausible numbers.
def seed_list!(creator, slug:, title:, description:, opens:, show_on_profile: true, socials:)
  list = creator.link_lists.find_or_initialize_by(slug: slug)
  list.assign_attributes(title: title, description: description, opens_count: opens,
                         show_on_profile: show_on_profile, published: true, socials: socials)
  list.save!
  list
end

products = ananya.product_links.reorder(:id).to_a
diwali = seed_list!(ananya, slug: "diwali", title: "My Diwali edit", opens: 2_180,
  description: "Everything I wore and used for the festive shoot", socials: %w[instagram youtube website])
if diwali.items.empty?
  products.first(3).each_with_index { |p, i| diwali.items.create!(product_link: p, position: i, clicks_count: [ 312, 188, 96 ][i]) }
  diwali.items.create!(url: "https://www.youtube.com/@ananyarao", title: "How I draped it: 6 min tutorial", position: 3, clicks_count: 64)
  diwali.items.create!(paid_media_collection: goa_set, position: 4, clicks_count: 41)
  diwali.items.create!(url: "https://ananyarao.example.com/blog/silk-saree-diwali", title: "5 ways to drape a silk saree for Diwali nights",
                       subtitle: "ananyarao.example.com/blog · 6 min read", image_url: REMOTE_IMAGES["rec-saree-silk"], position: 5, clicks_count: 7)
  diwali.items.create!(url: "https://ananyarao.example.com/blog/festive-shoot-packing", title: "What I pack for a two-day festive shoot",
                       subtitle: "ananyarao.example.com/blog · 4 min read", image_url: REMOTE_IMAGES["rec-saree-chiffon"], position: 6, clicks_count: 4)
end

grwm = seed_list!(ananya, slug: "grwm", title: "GRWM: wedding guest", opens: 964,
  description: "The full wedding-guest look, head to toe", socials: %w[instagram youtube])
if grwm.items.empty?
  products.drop(3).first(4).each_with_index { |p, i| grwm.items.create!(product_link: p, position: i, clicks_count: [ 120, 88, 54, 30 ][i]) }
  grwm.items.create!(paid_media_collection: festive, position: 4, clicks_count: 9)
end

kit = seed_list!(ananya, slug: "kit", title: "My shoot kit", opens: 268, show_on_profile: false,
  description: "Camera, light and the little things", socials: %w[instagram])
if kit.items.empty?
  products.last(4).each_with_index { |p, i| kit.items.create!(product_link: p, position: i, clicks_count: [ 30, 22, 12, 9 ][i]) }
end

# A fan who came from the Diwali list and owns Banarasi Heritage, so the
# viewer, "Yours" covers and the list's earnings all have something to show.
owned = claim!(creator: ananya, claimant: fans[0], purchasable: banarasi,
               amount_cents: 29_900, utr: "301122334455")
if owned
  owned.update!(link_list: diwali)
  owned.approve!(ananya)
end
claim!(creator: ananya, claimant: fans[4], purchasable: goa_set, amount_cents: 49_900, utr: "412288901734",
       note: "Paid on GPay")&.update!(link_list: diwali)

puts "  #{ananya.paid_media_collections.count} collections, #{ananya.link_lists.count} link lists"
puts "  Phone sign-in: +91 98201 44100 (Ananya) or +91 98765 43210 (Priya, a fan)"
puts "  @#{raya.handle}, @#{dev.handle} created"
puts "  #{User.count} users, #{CreatorFollow.count} follows, #{GiftContribution.count} gifts"
puts "  payment queue: #{PaymentClaim.pending.count} pending, #{PaymentClaim.where.not(status: "pending").count} reviewed"
puts "Done. Sign in as ananya@example.com / #{PASSWORD}"

# ---------------------------------------------------------------------------
# The roster: 50 creators with real profile pictures, spread across every
# category, all four themes and all three layouts, in cities around India.
#
# Everything a creator sees on their page comes from these records, including
# the section headings, which used to be hardcoded in the view. A few below
# set their own so the editable-heading path is exercised by real data rather
# ---------------------------------------------------------------------------
CREATOR_ROSTER = [
  { name: "Aanya Agarwal", handle: "aanyaagarwal", email: "aanyaagarwal@example.com", city: "Mumbai", category: "Saree Styling", subcategory: "Chiffon & Organza Drapes",
    theme: "minimal", layout: "editorial", pronouns: "she/her", bank: "okaxis", bio: "31 | Mumbai. Saree draper & reels creator. Celebrating fluid chiffons, clean pleats & modern drape silhouettes. Lookbooks in the Vault.", image: "c1.jpg" },
  { name: "Aditi Bhat", handle: "aditibhat", email: "aditibhat@example.com", city: "Delhi", category: "Ethnic GRWM", subcategory: "Wedding Guest Styling",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "33 | South Delhi. Handloom silk enthusiast & wedding GRWM creator. Elegant drapes, backless cuts & heritage aesthetics.", image: "c2.jpg" },
  { name: "Ahana Chandra", handle: "ahanachandra", email: "ahanachandra@example.com", city: "Bengaluru", category: "Reels & Glamour", subcategory: "Cinematic Saree Reels",
    theme: "adventure", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "30 | Bangalore. Cinematic reels creator & modern saree stylist. Slow-mo transitions and Indo-western drape aesthetics in 4K.", image: "c3.jpg" },
  { name: "Amrita Desai", handle: "amritadesai", email: "amritadesai@example.com", city: "Chennai", category: "Saree Styling", subcategory: "Handloom & Silk",
    theme: "after_dark", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "34 | Chennai. Kanjeevarams with modern twists. Exploring bold contrast blouses, temple jewelry & GRWM wedding series.", image: "c4.jpg" },
  { name: "Ananya Fernandes", handle: "ananyafernandes", email: "ananyafernandes@example.com", city: "Hyderabad", category: "Ethnic GRWM", subcategory: "Cocktail Saree Glam",
    theme: "minimal", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "32 | Hyderabad. Festive lookbooks, organza drapes & effortless GRWM transitions for evening cocktails and receptions.", image: "c5.jpg" },
  { name: "Anika Gupta", handle: "anikagupta", email: "anikagupta@example.com", city: "Pune", category: "Saree Styling", subcategory: "Pre-Stitched Drapes",
    theme: "luxury", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "30 | Pune. Chiffon saree fanatic & lifestyle reels creator. Sharing the secret to slip-free pleats and flattering silhouettes.", image: "c6.jpg" },
  { name: "Anjali Hegde", handle: "anjalihegde", email: "anjalihegde@example.com", city: "Kolkata", category: "Fashion & Fusion", subcategory: "Modern Blouse Cuts",
    theme: "adventure", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "35 | Kolkata. Vintage handlooms, cotton silks & artistic saree styling. Uncut drape tutorials & fitting room BTS in the Vault.", image: "c7.jpg" },
  { name: "Avni Iyer", handle: "avniiyer", email: "avniiyer@example.com", city: "Ahmedabad", category: "Reels & Glamour", subcategory: "Viral Drape Transitions",
    theme: "after_dark", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "32 | Ahmedabad. Pre-stitched and modern drape innovator. Fast GRWM reels, partywear sarees & statement waist accessories.", image: "c8.jpg" },
  { name: "Bhavya Joshi", handle: "bhavyajoshi", email: "bhavyajoshi@example.com", city: "Jaipur", category: "Saree Styling", subcategory: "Festive Silk Curations",
    theme: "minimal", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "33 | Jaipur. Royal heritage drapes, gota patti work & dramatic slow-mo reel walks across Jaipur palatial courtyards.", image: "c9.jpg" },
  { name: "Charvi Kapoor", handle: "charvikapoor", email: "charvikapoor@example.com", city: "Kochi", category: "Beauty & Adornment", subcategory: "Temple & Silver Jewelry",
    theme: "luxury", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "31 | Kochi. Coastal glam, tissue sarees & minimalist back designs. Daily GRWM & styling secrets in the Vault.", image: "c10.jpg" },
  { name: "Deepika Kulkarni", handle: "deepikakulkarni", email: "deepikakulkarni@example.com", city: "Chandigarh", category: "Ethnic GRWM", subcategory: "Festive GRWM",
    theme: "adventure", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "34 | Chandigarh. Pastel organza drapes, halter neck blouses & evening soiree GRWM styling.", image: "c11.jpg" },
  { name: "Divya Lal", handle: "divyalal", email: "divyalal@example.com", city: "Indore", category: "Reels & Glamour", subcategory: "Slow-Mo Aesthetic Walks",
    theme: "after_dark", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "30 | Indore. Reels creator specializing in aesthetic drape transitions, monsoon saree walks & cinematic camera tricks.", image: "c12.jpg" },
  { name: "Esha Mehta", handle: "eshamehta", email: "eshamehta@example.com", city: "Lucknow", category: "Saree Styling", subcategory: "Chiffon & Organza Drapes",
    theme: "minimal", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "32 | Lucknow. Chikankari sarees, sheer georgettes & delicate pearl jewelry. Graceful, feminine & modern ethnic looks.", image: "c13.jpg" },
  { name: "Gauri Nair", handle: "gaurinair", email: "gaurinair@example.com", city: "Goa", category: "Fashion & Fusion", subcategory: "Contemporary Ethnic",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "33 | Goa. Resort saree fashion, lightweight chiffons & beach sunset drape reels. Casual elegance redefined.", image: "c14.jpg" },
  { name: "Hansika Oberoi", handle: "hansikaoberoi", email: "hansikaoberoi@example.com", city: "Surat", category: "Fashion & Fusion", subcategory: "Statement Saree Styling",
    theme: "adventure", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "31 | Surat. High-glam partywear sarees, sequin drapes & corset blouse fits for red carpet & cocktail nights.", image: "c15.jpg" },
  { name: "Ira Pillai", handle: "irapillai", email: "irapillai@example.com", city: "Bhopal", category: "Saree Styling", subcategory: "Handloom & Silk",
    theme: "after_dark", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "35 | Bhopal. Classic Chanderi silks, monochrome drapes & high-res analog photo archives. Timeless South Asian elegance.", image: "c16.jpg" },
  { name: "Ishita Qureshi", handle: "ishitaqureshi", email: "ishitaqureshi@example.com", city: "Nagpur", category: "Ethnic GRWM", subcategory: "Blouse Styling & Fits",
    theme: "minimal", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "30 | Nagpur. Festive saree styling, bold cut blouses & rapid GRWM reels for bridesmaids and wedding guests.", image: "c17.jpg" },
  { name: "Janvi Rao", handle: "janvirao", email: "janvirao@example.com", city: "Coimbatore", category: "Saree Styling", subcategory: "Festive Silk Curations",
    theme: "luxury", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "33 | Coimbatore. Temple borders, pure silks & structured drapes. Helping women embrace heritage weaves with confidence.", image: "c18.jpg" },
  { name: "Kavya Reddy", handle: "kavyareddy", email: "kavyareddy@example.com", city: "Guwahati", category: "Fashion & Fusion", subcategory: "Indo-Western Drapes",
    theme: "adventure", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "32 | Guwahati. Assam silk and Mekhela Sador styling with modern cuts. Unique drape reels & close-up textures.", image: "c19.jpg" },
  { name: "Keerthi Sharma", handle: "keerthisharma", email: "keerthisharma@example.com", city: "Dehradun", category: "Reels & Glamour", subcategory: "Cinematic Saree Reels",
    theme: "after_dark", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "31 | Dehradun. Hillside golden hour reels, velvet shawls with chiffon sarees & aesthetic winter drape looks.", image: "c20.jpg" },
  { name: "Lavanya Shetty", handle: "lavanyashetty", email: "lavanyashetty@example.com", city: "Mumbai", category: "Saree Styling", subcategory: "Editorial Saree Modeling",
    theme: "minimal", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "34 | Bandra, Mumbai. Editorial saree model & fitness enthusiast. Drapes that flatter curves, mermaid shapewear secrets.", image: "c21.jpg" },
  { name: "Maithili Singh", handle: "maithilisingh", email: "maithilisingh@example.com", city: "Delhi", category: "Fashion & Fusion", subcategory: "Cocktail Couture",
    theme: "luxury", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "32 | Delhi. Saree styling for corporate events by day, cocktail glamour by night. Chic, sharp & polished.", image: "c22.jpg" },
  { name: "Meera Tandon", handle: "meeratandon", email: "meeratandon@example.com", city: "Bengaluru", category: "Ethnic GRWM", subcategory: "Wedding Guest Styling",
    theme: "adventure", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "33 | Bengaluru. South silk styling, contrast blouse curation & festive GRWM reels for modern working women.", image: "c23.jpg" },
  { name: "Mitali Verma", handle: "mitaliverma", email: "mitaliverma@example.com", city: "Chennai", category: "Fashion & Fusion", subcategory: "Indo-Western Drapes",
    theme: "after_dark", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "30 | Chennai. Modern fusion drapes, saree over trousers, belt styling & viral transition reels.", image: "c24.jpg" },
  { name: "Naina Wadhwa", handle: "nainawadhwa", email: "nainawadhwa@example.com", city: "Hyderabad", category: "Beauty & Adornment", subcategory: "Traditional Adornments",
    theme: "minimal", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "35 | Hyderabad. Royal Nizam-inspired heritage drapes, velvet blouses & high-jewelry pairing masterclasses.", image: "c25.jpg" },
  { name: "Navya Bose", handle: "navyabose", email: "navyabose@example.com", city: "Pune", category: "Reels & Glamour", subcategory: "Slow-Mo Aesthetic Walks",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "31 | Pune. Slow-mo reels creator, aesthetic sound design & flowy chiffon drapes in the monsoon.", image: "c26.jpg" },
  { name: "Neha Chopra", handle: "nehachopra", email: "nehachopra@example.com", city: "Kolkata", category: "Fashion & Fusion", subcategory: "Modern Blouse Cuts",
    theme: "adventure", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "33 | Kolkata. Taant & Tussar silk reimagined. Modern halter necklines, dramatic pallu falls & creative photography.", image: "c27.jpg" },
  { name: "Nikita Dutta", handle: "nikitadutta", email: "nikitadutta@example.com", city: "Ahmedabad", category: "Ethnic GRWM", subcategory: "Festive GRWM",
    theme: "after_dark", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "32 | Ahmedabad. Mirror-work sarees, festive Navratri drapes & backless choli inspirations.", image: "c28.jpg" },
  { name: "Oviya Ghosh", handle: "oviyaghosh", email: "oviyaghosh@example.com", city: "Jaipur", category: "Saree Styling", subcategory: "Chiffon & Organza Drapes",
    theme: "minimal", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "34 | Jaipur. Bandhani & Leheriya styling, vibrant color blocking & desert sunset lookbooks in 4K.", image: "c29.jpg" },
  { name: "Pallavi Krishnan", handle: "pallavikrishnan", email: "pallavikrishnan@example.com", city: "Kochi", category: "Beauty & Adornment", subcategory: "Classic Hair & Gajra",
    theme: "luxury", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "32 | Kochi. Kasavu saree reinvention, temple gold jewelry & peaceful aesthetic morning GRWM routines.", image: "c30.jpg" },
  { name: "Prisha Menon", handle: "prishamenon", email: "prishamenon@example.com", city: "Chandigarh", category: "Ethnic GRWM", subcategory: "Wedding Guest Styling",
    theme: "adventure", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "30 | Chandigarh. Big fat wedding GRWM series, heavy bridal sarees & designer blouse back cutouts.", image: "c31.jpg" },
  { name: "Radhika Nayar", handle: "radhikanayar", email: "radhikanayar@example.com", city: "Indore", category: "Fashion & Fusion", subcategory: "Contemporary Ethnic",
    theme: "after_dark", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "33 | Indore. Traditional Maheshwari weaves paired with contemporary crop tops and modern waist belts.", image: "c32.jpg" },
  { name: "Riya Pandit", handle: "riyapandit", email: "riyapandit@example.com", city: "Lucknow", category: "Saree Styling", subcategory: "Chiffon & Organza Drapes",
    theme: "minimal", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "31 | Lucknow. Soft georgette drapes, romantic pastels & slow-living ethnic lifestyle reels.", image: "c33.jpg" },
  { name: "Saanvi Raman", handle: "saanviraman", email: "saanviraman@example.com", city: "Goa", category: "Reels & Glamour", subcategory: "Cinematic Saree Reels",
    theme: "luxury", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "34 | Goa. Bohemian ethnic wear, modern drapes & sunset rooftop cocktail saree sessions in 4K.", image: "c34.jpg" },
  { name: "Sanjana Saxena", handle: "sanjanasaxena", email: "sanjanasaxena@example.com", city: "Surat", category: "Ethnic GRWM", subcategory: "Blouse Styling & Fits",
    theme: "adventure", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "32 | Surat. Textile insider sharing pure vs synthetic drape tests, blouse fitting guides & GRWM try-ons.", image: "c35.jpg" },
  { name: "Sara Thakur", handle: "sarathakur", email: "sarathakur@example.com", city: "Bhopal", category: "Reels & Glamour", subcategory: "Viral Drape Transitions",
    theme: "after_dark", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "30 | Bhopal. Saree reels creator with 1M+ views on pleat hacks and walking transitions. Daily tutorials.", image: "c36.jpg" },
  { name: "Shreya Varma", handle: "shreyavarma", email: "shreyavarma@example.com", city: "Nagpur", category: "Saree Styling", subcategory: "Handloom & Silk",
    theme: "minimal", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "33 | Nagpur. Paithani silks, rich borders & modern sweetheart neckline blouses. Graceful Maharashtrian glam.", image: "c37.jpg" },
  { name: "Simran Banerjee", handle: "simranbanerjee", email: "simranbanerjee@example.com", city: "Coimbatore", category: "Ethnic GRWM", subcategory: "Festive GRWM",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "31 | Coimbatore. Draping made effortless. Quick 60-second GRWM reels for busy festival mornings.", image: "c38.jpg" },
  { name: "Sneha Chatterjee", handle: "snehachatterjee", email: "snehachatterjee@example.com", city: "Guwahati", category: "Saree Styling", subcategory: "Handloom & Silk",
    theme: "adventure", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "35 | Guwahati. Muga silk collections, festive handlooms & authentic behind-the-scenes draping stories.", image: "c39.jpg" },
  { name: "Tanvi Dixit", handle: "tanvidixit", email: "tanvidixit@example.com", city: "Dehradun", category: "Fashion & Fusion", subcategory: "Contemporary Ethnic",
    theme: "after_dark", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "32 | Dehradun. Cozy ethnic winter styling, pashmina pairings & soft chiffon evening looks.", image: "c40.jpg" },
  { name: "Tara Kaur", handle: "tarakaur", email: "tarakaur@example.com", city: "Mumbai", category: "Ethnic GRWM", subcategory: "Cocktail Saree Glam",
    theme: "minimal", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "33 | Mumbai. Modern festive guest lookbooks, metallic sarees & backless blouse draping.", image: "c41.jpg" },
  { name: "Trisha Malhotra", handle: "trishamalhotra", email: "trishamalhotra@example.com", city: "Delhi", category: "Fashion & Fusion", subcategory: "Statement Saree Styling",
    theme: "luxury", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "34 | Delhi. High-fashion ethnic lookbooks, designer sarees, bespoke tailoring & wardrobe organization.", image: "c42.jpg" },
  { name: "Vaishnavi Narayan", handle: "vaishnavinarayan", email: "vaishnavinarayan@example.com", city: "Bengaluru", category: "Saree Styling", subcategory: "Festive Silk Curations",
    theme: "adventure", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "31 | Bengaluru. Mysore silks, traditional elegance & step-by-step drape reels for beginners.", image: "c43.jpg" },
  { name: "Vanya Patel", handle: "vanyapatel", email: "vanyapatel@example.com", city: "Chennai", category: "Fashion & Fusion", subcategory: "Indo-Western Drapes",
    theme: "after_dark", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "30 | Chennai. Contemporary fusion drapes, jacket blouses & architectural saree silhouettes.", image: "c44.jpg" },
  { name: "Vedika Rathore", handle: "vedikarathore", email: "vedikarathore@example.com", city: "Hyderabad", category: "Beauty & Adornment", subcategory: "Traditional Adornments",
    theme: "minimal", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "35 | Hyderabad. Regal heritage drapes, heirloom jewelry stories & 4K cinematic lookbooks.", image: "c45.jpg" },
  { name: "Yamini Sen", handle: "yaminisen", email: "yaminisen@example.com", city: "Pune", category: "Saree Styling", subcategory: "Chiffon & Organza Drapes",
    theme: "luxury", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "32 | Pune. Saree model & content creator. Pure chiffons, organzas & sensual, elegant drape transitions.", image: "c46.jpg" },
  { name: "Zara Trivedi", handle: "zaratrivedi", email: "zaratrivedi@example.com", city: "Kolkata", category: "Ethnic GRWM", subcategory: "Cocktail Saree Glam",
    theme: "adventure", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "31 | Kolkata. Modern glam, red-carpet ethnic silhouettes & uncut dressing room BTS footage in the Vault.", image: "c47.jpg" },
  { name: "Ritika Upadhyay", handle: "ritikaupadhyay", email: "ritikaupadhyay@example.com", city: "Ahmedabad", category: "Ethnic GRWM", subcategory: "Festive GRWM",
    theme: "after_dark", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "33 | Ahmedabad. Festive Gujarati drapes, Patola silks & vibrant wedding guest inspirations.", image: "c48.jpg" },
  { name: "Nandini Vora", handle: "nandinivora", email: "nandinivora@example.com", city: "Jaipur", category: "Reels & Glamour", subcategory: "Cinematic Saree Reels",
    theme: "minimal", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "34 | Jaipur. Royal heritage couture, palace photoshoot lookbooks & 4K cinematic slow-motion reels.", image: "c49.jpg" },
  { name: "Diya Yadav", handle: "diyayadav", email: "diyayadav@example.com", city: "Kochi", category: "Beauty & Adornment", subcategory: "Classic Hair & Gajra",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "30 | Kochi. Minimalist Kerala drapes, contemporary blouses & clean, aesthetic GRWM videos.", image: "c50.jpg" }
].freeze

CATEGORY_CONTENT = {
  "Saree Styling" => [ "My Saree Wardrobe & Go-To Drapes", [
    [ "Pure Chiffon Saree with Sequin Border", "Swtantra", "₹3,499", "Drapes like liquid glass. The exact piece from my monsoon balcony reel that crossed a million views." ],
    [ "Raw Silk Backless Blouse", "Nykaa Fashion", "₹1,899", "Structured fit, deep cut, and padded so you never have to wrestle with tape or visible straps." ],
    [ "Saree Shapewear Mermaid Skirt", "Zivame", "₹1,299", "The secret to clean pleats and a structured fall. I will never go back to drawstring cotton petticoats." ]
  ] ],
  "Ethnic GRWM" => [ "GRWM Essentials & Skin Prep", [
    [ "Hydrating Dewy Primer Serum", "Nykaa", "₹649", "Skin prep before six hours under studio lights. Keeps heavy ethnic makeup from creasing." ],
    [ "Matte Velvet Lip Stain, Brick Red", "Nykaa", "₹450", "The classic wedding guest red that doesn't bleed onto collarbones or cups." ],
    [ "Setting Spray that Survives Humidity", "Nykaa", "₹550", "Tested through 35°C outdoor shoots in Bombay. My base did not budge until midnight." ]
  ] ],
  "Reels & Glamour" => [ "Kit I Shoot 4K Reels On", [
    [ "The camera I shoot all 4K reels on", "Amazon", "₹64,999", "Crisp 4K 60fps slow-mo drape walks. The sensor captures every thread and texture of silk." ],
    [ "Studio Ring Light with Phone Mount", "Amazon", "₹2,299", "Soft, diffused golden light for GRWM vanity clips. Eliminates harsh overhead apartment shadows." ],
    [ "Wireless Lapel Mic for Voiceovers", "Amazon", "₹3,899", "Captures the authentic rustle of silk sarees and crisp audio for drape tutorials." ]
  ] ],
  "Fashion & Fusion" => [ "Modern Blouses & Fusion Fits", [
    [ "Halter Neck Brocade Blouse", "Nykaa Fashion", "₹1,699", "Pair it with plain chiffon or georgette to instantly elevate a minimalist drape." ],
    [ "Handcrafted Silver Kamarbandh", "FabIndia", "₹2,850", "Accentuates the waistline on plain georgette and chiffon drapes instantly." ],
    [ "Pre-Stitched Ruffled Saree", "Myntra", "₹2,799", "Ready in two minutes. Perfect for cocktail evenings when you have zero time to pleat." ]
  ] ],
  "Beauty & Adornment" => [ "Jewelry & Statement Accents", [
    [ "Antique Gold Jhumkas with Pearls", "Tribe Amrapali", "₹3,200", "Heavy look without the ear-pulling weight. My most asked-about piece in reel comments." ],
    [ "Velvet Zardozi Potli Bag", "Nykaa Fashion", "₹1,450", "Fits the phone, lipstick, and keys without bulging. The only wedding clutch you need." ],
    [ "Handmade Jasmine Gajra Hair Pin", "Amazon", "₹399", "Realistic, fragrant finish that stays firmly pinned into a sleek low bun all evening." ]
  ] ]
}.freeze

CUSTOM_HEADINGS = {
  "Saree Styling"      => { links_heading: "My Wardrobe & Favorite Drapes", media_heading: "The Vault: 4K Saree Lookbooks", meet_heading: "1:1 Drape Masterclass & Posing" },
  "Ethnic GRWM"        => { links_heading: "GRWM Essentials & Blouse Fits", media_heading: "The Vault: Uncut Fitting BTS", meet_heading: "1:1 Wedding Guest Styling Call" },
  "Reels & Glamour"    => { links_heading: "Camera Kit & Shoot Gear", media_heading: "The Vault: 4K Cinematic Reel Sets", meet_heading: "1:1 Reel Transition & Coaching" },
  "Fashion & Fusion"   => { links_heading: "Curated Blouse Cuts & Fits", media_heading: "The Vault: Exclusive Lookbooks", meet_heading: "1:1 Personal Styling Session" },
  "Beauty & Adornment" => { links_heading: "Jewelry, Potlis & Skin Prep", media_heading: "The Vault: High-Res Glamour Sets", meet_heading: "1:1 Ethnic Makeup & Hair Consult" }
}.freeze

roster_users = CREATOR_ROSTER.each_with_index.map do |row, i|
  creator = upsert_user!(
    row[:email],
    name: row[:name], handle: row[:handle], bio: row[:bio],
    pronouns: row[:pronouns], location: "#{row[:city]}, India",
    creator_category: row[:category], creator_subcategory: row[:subcategory],
    theme: row[:theme], profile_layout: row[:layout], account_type: "creator",
    instagram_handle: row[:handle],
    youtube_handle: (row[:handle] if i.even?),
    public_email: "hello@#{row[:handle]}.example.com",
    upi_id: "#{row[:handle]}@#{row[:bank]}",
    upi_payee_name: row[:name], accepts_upi_manual: true,
    **CUSTOM_HEADINGS.fetch(row[:category], {})
  )

  attach_image(creator, :profile_picture, "creators/#{row[:image]}")
  attach_image(creator, :banner, "creator-saree.jpg")

  coll_name, items = CATEGORY_CONTENT.fetch(row[:category])
  collection = creator.link_collections.find_or_create_by!(name: coll_name)
  items.each_with_index do |(title, merchant, price, reason), n|
    link = creator.product_links.find_or_initialize_by(title: title)
    link.assign_attributes(url: "https://example.com/#{title.parameterize}",
      merchant: merchant, price: price, description: reason,
      link_collection: collection, featured: n.zero?)
    link.save!
  end

  # Not everyone sells everything: spreading this out shows pages at different
  # stages of setup rather than fifty identical ones.
  if (i % 3).zero?
    titles = [
      [ "Monsoon Chiffon Balcony Walk (4K Reel Set, 36 photos)", "Slow-motion rain and sheer chiffon drape series. 4K high-resolution, unedited frames.", 49_900 ],
      [ "GRWM: Wedding Guest Fitting & Blouse BTS (4K Video, 11 mins)", "Uncut try-on footage, pleated pallu tutorial, and blouse fitting room clips. Raw audio.", 79_900 ],
      [ "Golden Hour Organza Drape in 4K (Vault Lookbook, 30 photos)", "Sun-drenched terrace session in pastel organza with pearl accents. Crisp 4K captures.", 59_900 ],
      [ "Backless Velvet Blouse & Heritage Silk Set (4K Stills)", "Deep-cut bespoke velvet blouse paired with handwoven Katan silk. High-res archive set.", 44_900 ],
      [ "Cocktail Georgette Drape & Transition Pack (4K 60fps Reels)", "6 cinematic slow-mo walking clips and seamless reel transitions. Ready-to-watch 4K cuts.", 89_900 ],
      [ "Midnight Silk Bedroom Archive (35mm Film, 26 frames)", "Late night session in raw silk and antique jewelry. 26 analog scans.", 39_900 ]
    ]
    title, caption, price = titles[i % titles.size]
    post = creator.paid_media_posts.find_or_initialize_by(title: title)
    post.assign_attributes(caption: caption, price_cents: price, currency: "INR",
      media_type: (title.include?("Video") || title.include?("Reels") ? "video" : "image"), published: true)
    attach_image(post, :media, "creators/#{row[:image]}")
    attach_image(post, :preview, "creators/#{row[:image]}")
    post.save!
  end

  if (i % 4).zero?
    labels = [
      "Private Close Friends VIP WhatsApp (Direct DMs & Daily Stories)",
      "Personal Telegram VIP Channel (Voice Notes & Uncut Reels)",
      "VIP Close Friends Pass (Direct Access & Unfiltered Snaps)"
    ]
    label = labels[i % labels.size]
    reveal = creator.contact_reveals.find_or_initialize_by(label: label)
    reveal.assign_attributes(secret_value: "+91 9#{(800_000_000 + i * 7919)}"[0, 15],
      price_cents: [ 49_900, 99_900, 149_900 ][i % 3], currency: "INR", published: true)
    reveal.save!
  end

  if (i % 5).zero?
    wl = creator.wishlists.find_or_initialize_by(title: "Spoil Me & Shoot Wardrobe ✨")
    wl.assign_attributes(description: "Help fund pieces for upcoming festive lookbooks, bespoke blouses and 4K Vault reel productions.", published: true)
    wl.save!
    wish_items = [
      [ "Bespoke Raw Silk Backless Blouse Set", 12_500_00, "For upcoming festive lookbook shoots." ],
      [ "Raw Mango Handwoven Silk Saree", 28_000_00, "Heritage drape piece for the royal palace series." ],
      [ "Dyson Airwrap Multi-Styler Complete", 45_900_00, "For quick voluminous curls during GRWM shoot changes." ],
      [ "Handcrafted Silver Kamarbandh with Pearls", 9_500_00, "Statement waist adornment for chiffon drape reels." ],
      [ "Sony 50mm f/1.4 GM Prime Lens", 74_000_00, "For creamy bokeh in 4K slow-mo saree walks." ],
      [ "Luxury Day Spa at Taj Lands End", 14_000_00, "Relaxation day after a 3-day festive shooting marathon." ]
    ]
    item_title, target, note = wish_items[i % wish_items.size]
    it = wl.wishlist_items.find_or_initialize_by(title: item_title)
    it.assign_attributes(target_cents: target, currency: "INR", note: note)
    it.save!
  end

  if (i % 2).zero?
    body = [
      "Just wrapped the golden hour chiffon saree shoot! Editing the 4K slow-mo reel set now — drops in the Vault tonight! 🔥",
      "GRWM poll: Deep V-cut velvet blouse or high-neck halter for tomorrow's cocktail reel? Let me know in comments! 💫",
      "Uncut 12-minute drape & blouse fitting video is live for VIP Close Friends. Check your Vault access! 💖",
      "Behind the scenes of that viral saree transition reel is up on Telegram VIP. Link in bio! ✨",
      "Answering all drape styling questions in DMs tonight. VIP members get first priority replies! 💌"
    ][i % 5]
    p = creator.creator_posts.find_or_initialize_by(body: body)
    p.published = true
    p.save!
  end

  creator
end

# Follows across the roster, deterministic so a re-seed does not drift.
roster_users.each_with_index do |creator, i|
  roster_users.rotate(i + 1).first((i * 7 % 23) + 1).each do |follower|
    next if follower == creator
    CreatorFollow.find_or_create_by!(creator: creator, follower: follower)
  end
end
fans.each do |fan|
  roster_users.first(12).each { |c| CreatorFollow.find_or_create_by!(creator: c, follower: fan) }
end

puts "  roster: #{roster_users.size} creators, #{roster_users.count { |c| c.profile_picture.attached? }} with photos"
puts "  follows: #{CreatorFollow.count}"
puts "  renamed sections: #{User.where.not(links_heading: nil).count} creators"
