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
  "rec-denim.jpg"  => "https://images.unsplash.com/photo-1542272604-787c3835535d?w=240&q=72&auto=format&fit=crop",
  "rec-serum.jpg"  => "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=240&q=72&auto=format&fit=crop",
  "rec-camera.jpg" => "https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400&q=72&auto=format&fit=crop"
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
  bio: "Thrift finds, the three products I actually repurchase, and whatever " \
       "I am wearing to the airport. Mumbai. Replies to everyone eventually.",
  pronouns: "she/her",
  location: "Mumbai, India",
  creator_category: "Fashion",
  creator_subcategory: "Thrift and second-hand",
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
  date_of_birth: Date.new(1998, 4, 12)
)
attach_image(ananya, :profile_picture, "creator-portrait.jpg")
attach_image(ananya, :banner, "creator-saree.jpg")

# --- collections and recommendations ---------------------------------------
# Each reason is a sentence a person would actually say. The card leads with
# the reason, so a recommendation without one renders as a bare product name.

collections = {
  "The thrift haul" => [
    [ "Levi's 501, 1990s", "Myntra", "₹2,499", "rec-denim.jpg",
      "Found these in a Bandra bin for less than a cab fare. The fade is real, not sanded on at a factory.", true ],
    [ "Oversized denim jacket", "Myntra", "₹1,899", nil,
      "Men's large, worn as a dress in October. It is the only jacket that survives Bombay weather." ],
    [ "Silk scarf, unbranded", "Myntra", "₹450", nil,
      "Four rupees short of nothing and I have used it as a bag strap, a hairband and a belt." ]
  ],
  "Three things I repurchase" => [
    [ "The sunscreen, finally", "Nykaa", "₹649", "rec-serum.jpg",
      "Eighth tube. No white cast, does not sting, and it does not slide off by 2pm in this humidity." ],
    [ "Cleanser that does not strip", "Nykaa", "₹390", nil,
      "My skin stopped feeling tight after a week. That is the whole review." ],
    [ "Lip balm, the boring one", "Nykaa", "₹220", nil,
      "No tint, no shimmer, no scent. Works." ]
  ],
  "Kit I shoot on" => [
    [ "The camera I actually use", "Amazon", "₹41,999", "rec-camera.jpg",
      "Everything on this page was shot on this body. I am not upgrading until it dies." ],
    [ "Ring light, the small one", "Amazon", "₹1,299", nil,
      "Fits in a tote. I have shot a whole reel in an auto with this." ],
    [ "Tripod that folds flat", "Amazon", "₹899", nil,
      "Cheap, plastic, been dropped four times, still holds." ]
  ],
  "Home, slowly" => [
    [ "The softest throw", "Sunday Home", "₹2,499", nil,
      "Bought it for the sofa, ended up taking it on every flight since." ],
    [ "Brass diya set", "Sunday Home", "₹1,150", nil,
      "My mother's approval, which is the only review that matters at Diwali." ],
    [ "Storage baskets, set of three", "Sunday Home", "₹780", nil,
      "The reason my desk is visible in any of my videos." ],
    [ "Cotton bedsheets", "Sunday Home", "₹1,890", nil,
      "Third summer on these and they have gone softer, not thinner." ]
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
  [ "The full Goa set, 48 photos", "Everything from the December trip, unedited and edited.", 49_900, "creator-saree.jpg" ],
  [ "How I actually edit a reel", "Screen recording, 14 minutes, no cuts.", 29_900, "creator-portrait.jpg" ]
].each do |title, caption, price_cents, preview|
  post = ananya.paid_media_posts.find_or_initialize_by(title: title)
  post.assign_attributes(
    caption: caption, price_cents: price_cents, currency: "INR",
    media_type: "image", published: true
  )
  attach_image(post, :media, preview)
  attach_image(post, :preview, preview)
  post.save!
end

# --- a meetup with real, future slots --------------------------------------

meet = ananya.meet_offers.find_or_initialize_by(title: "Closet audit, in person")
meet.assign_attributes(
  description: "Bring everything you do not wear. We go through it together and " \
               "you leave with a list of what actually works on you.",
  location: "Bandra West, Mumbai",
  duration_minutes: 40,
  price_cents: 120_000,
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

reveal = ananya.contact_reveals.find_or_initialize_by(label: "My WhatsApp, for brand enquiries only")
reveal.assign_attributes(
  secret_value: "+91 98200 00000", price_cents: 19_900, currency: "INR", published: true
)
reveal.save!

# --- gift wishlist ---------------------------------------------------------
# Deliberately spread across funding states so the progress meter shows
# empty, partial and funded on one page.

studio = ananya.wishlists.find_or_initialize_by(title: "Studio fund")
studio.assign_attributes(
  description: "Saving towards a room I can actually shoot in, instead of my bedroom floor.",
  published: true
)
studio.save!

[
  [ "35mm lens", 45_000_00, "The one lens I keep borrowing and giving back." ],
  [ "Proper softbox", 12_000_00, "So I stop shooting everything at 4pm by the window." ],
  [ "Backdrop stand", 4_500_00, "Cheap, and it would change every flatlay on this page." ]
].each do |title, target_cents, note|
  item = studio.wishlist_items.find_or_initialize_by(title: title)
  item.assign_attributes(target_cents: target_cents, currency: "INR", note: note)
  item.save!
end

# --- subscription plan -----------------------------------------------------

plan = ananya.subscription_plans.find_or_initialize_by(name: "The monthly")
plan.assign_attributes(
  description: "Everything I post behind a price, plus the edits I do not publish.",
  price_cents: 29_900, currency: "INR", active: true
)
plan.save!

# --- posts -----------------------------------------------------------------

[
  "Shot the whole summer set today and I am never shooting in May again. Editing tonight, up tomorrow.",
  "Someone asked for the sunscreen link for the ninth time this week so it is pinned at the top now.",
  "Thrift run on Sunday. If you want me to look for something specific, reply here and I will keep an eye out."
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

goa   = ananya.paid_media_posts.find_by(title: "The full Goa set, 48 photos")
edit  = ananya.paid_media_posts.find_by(title: "How I actually edit a reel")
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
# than only by an empty settings form.
# ---------------------------------------------------------------------------
CREATOR_ROSTER = [
  { name: "Aanya Agarwal", handle: "aanyaagarwal", email: "aanyaagarwal@example.com", city: "Mumbai", category: "Fashion", subcategory: "Thrift and second-hand",
    theme: "minimal", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "Thrift finds, what actually fits, and the tailor who saves everything.", image: "c1.jpg" },
  { name: "Aditi Bhat", handle: "aditibhat", email: "aditibhat@example.com", city: "Delhi", category: "Beauty", subcategory: "Makeup",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "Only the products I finished the bottle of. Oily skin, Indian weather.", image: "c2.jpg" },
  { name: "Ahana Chandra", handle: "ahanachandra", email: "ahanachandra@example.com", city: "Bengaluru", category: "Fitness", subcategory: "Running",
    theme: "adventure", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "Strength training in a 1BHK. Form over weight, always.", image: "c3.jpg" },
  { name: "Amrita Desai", handle: "amritadesai", email: "amritadesai@example.com", city: "Chennai", category: "Travel", subcategory: "Food trails",
    theme: "after_dark", layout: "classic", pronouns: "she/they", bank: "okicici", bio: "Cheap routes, real budgets, and where to eat near the bus stand.", image: "c4.jpg" },
  { name: "Ananya Fernandes", handle: "ananyafernandes", email: "ananyafernandes@example.com", city: "Hyderabad", category: "Food", subcategory: "Home cooking",
    theme: "minimal", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "Recipes from my grandmother, written down before I forget them.", image: "c5.jpg" },
  { name: "Anika Gupta", handle: "anikagupta", email: "anikagupta@example.com", city: "Pune", category: "Lifestyle", subcategory: "Organisation",
    theme: "luxury", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "Small flat, fewer things, better mornings.", image: "c6.jpg" },
  { name: "Anjali Hegde", handle: "anjalihegde", email: "anjalihegde@example.com", city: "Kolkata", category: "Art & design", subcategory: "Textile",
    theme: "adventure", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "Everything here is made by hand. Slowly.", image: "c7.jpg" },
  { name: "Avni Iyer", handle: "avniiyer", email: "avniiyer@example.com", city: "Ahmedabad", category: "Music", subcategory: "Indie",
    theme: "after_dark", layout: "editorial", pronouns: "she/they", bank: "oksbi", bio: "Covers, riyaaz notes, and the mic I finally saved up for.", image: "c8.jpg" },
  { name: "Bhavya Joshi", handle: "bhavyajoshi", email: "bhavyajoshi@example.com", city: "Jaipur", category: "Gaming", subcategory: "Reviews",
    theme: "minimal", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "Mobile first, because that is what most of us actually own.", image: "c9.jpg" },
  { name: "Charvi Kapoor", handle: "charvikapoor", email: "charvikapoor@example.com", city: "Kochi", category: "Fashion", subcategory: "Ethnic wear",
    theme: "luxury", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "Thrift finds, what actually fits, and the tailor who saves everything.", image: "c10.jpg" },
  { name: "Deepika Kulkarni", handle: "deepikakulkarni", email: "deepikakulkarni@example.com", city: "Chandigarh", category: "Beauty", subcategory: "Haircare",
    theme: "adventure", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "Only the products I finished the bottle of. Oily skin, Indian weather.", image: "c11.jpg" },
  { name: "Divya Lal", handle: "divyalal", email: "divyalal@example.com", city: "Indore", category: "Fitness", subcategory: "Home workouts",
    theme: "after_dark", layout: "gallery", pronouns: "she/they", bank: "paytm", bio: "Strength training in a 1BHK. Form over weight, always.", image: "c12.jpg" },
  { name: "Esha Mehta", handle: "eshamehta", email: "eshamehta@example.com", city: "Lucknow", category: "Travel", subcategory: "Budget travel",
    theme: "minimal", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "Cheap routes, real budgets, and where to eat near the bus stand.", image: "c13.jpg" },
  { name: "Gauri Nair", handle: "gaurinair", email: "gaurinair@example.com", city: "Goa", category: "Food", subcategory: "Baking",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "Recipes from my grandmother, written down before I forget them.", image: "c14.jpg" },
  { name: "Hansika Oberoi", handle: "hansikaoberoi", email: "hansikaoberoi@example.com", city: "Surat", category: "Lifestyle", subcategory: "Journaling",
    theme: "adventure", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "Small flat, fewer things, better mornings.", image: "c15.jpg" },
  { name: "Ira Pillai", handle: "irapillai", email: "irapillai@example.com", city: "Bhopal", category: "Art & design", subcategory: "Photography",
    theme: "after_dark", layout: "classic", pronouns: "she/they", bank: "okicici", bio: "Everything here is made by hand. Slowly.", image: "c16.jpg" },
  { name: "Ishita Qureshi", handle: "ishitaqureshi", email: "ishitaqureshi@example.com", city: "Nagpur", category: "Music", subcategory: "Singing",
    theme: "minimal", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "Covers, riyaaz notes, and the mic I finally saved up for.", image: "c17.jpg" },
  { name: "Janvi Rao", handle: "janvirao", email: "janvirao@example.com", city: "Coimbatore", category: "Gaming", subcategory: "Reviews",
    theme: "luxury", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "Mobile first, because that is what most of us actually own.", image: "c18.jpg" },
  { name: "Kavya Reddy", handle: "kavyareddy", email: "kavyareddy@example.com", city: "Guwahati", category: "Fashion", subcategory: "Streetwear",
    theme: "adventure", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "Thrift finds, what actually fits, and the tailor who saves everything.", image: "c19.jpg" },
  { name: "Keerthi Sharma", handle: "keerthisharma", email: "keerthisharma@example.com", city: "Dehradun", category: "Beauty", subcategory: "Fragrance",
    theme: "after_dark", layout: "editorial", pronouns: "she/they", bank: "oksbi", bio: "Only the products I finished the bottle of. Oily skin, Indian weather.", image: "c20.jpg" },
  { name: "Lavanya Shetty", handle: "lavanyashetty", email: "lavanyashetty@example.com", city: "Mumbai", category: "Fitness", subcategory: "Strength",
    theme: "minimal", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "Strength training in a 1BHK. Form over weight, always.", image: "c21.jpg" },
  { name: "Maithili Singh", handle: "maithilisingh", email: "maithilisingh@example.com", city: "Delhi", category: "Travel", subcategory: "Solo travel",
    theme: "luxury", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "Cheap routes, real budgets, and where to eat near the bus stand.", image: "c22.jpg" },
  { name: "Meera Tandon", handle: "meeratandon", email: "meeratandon@example.com", city: "Bengaluru", category: "Food", subcategory: "Regional food",
    theme: "adventure", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "Recipes from my grandmother, written down before I forget them.", image: "c23.jpg" },
  { name: "Mitali Verma", handle: "mitaliverma", email: "mitaliverma@example.com", city: "Chennai", category: "Lifestyle", subcategory: "Plants",
    theme: "after_dark", layout: "gallery", pronouns: "she/they", bank: "paytm", bio: "Small flat, fewer things, better mornings.", image: "c24.jpg" },
  { name: "Naina Wadhwa", handle: "nainawadhwa", email: "nainawadhwa@example.com", city: "Hyderabad", category: "Art & design", subcategory: "Illustration",
    theme: "minimal", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "Everything here is made by hand. Slowly.", image: "c25.jpg" },
  { name: "Navya Bose", handle: "navyabose", email: "navyabose@example.com", city: "Pune", category: "Music", subcategory: "Production",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "Covers, riyaaz notes, and the mic I finally saved up for.", image: "c26.jpg" },
  { name: "Neha Chopra", handle: "nehachopra", email: "nehachopra@example.com", city: "Kolkata", category: "Gaming", subcategory: "Reviews",
    theme: "adventure", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "Mobile first, because that is what most of us actually own.", image: "c27.jpg" },
  { name: "Nikita Dutta", handle: "nikitadutta", email: "nikitadutta@example.com", city: "Ahmedabad", category: "Fashion", subcategory: "Sustainable",
    theme: "after_dark", layout: "classic", pronouns: "she/they", bank: "okicici", bio: "Thrift finds, what actually fits, and the tailor who saves everything.", image: "c28.jpg" },
  { name: "Oviya Ghosh", handle: "oviyaghosh", email: "oviyaghosh@example.com", city: "Jaipur", category: "Beauty", subcategory: "Skincare",
    theme: "minimal", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "Only the products I finished the bottle of. Oily skin, Indian weather.", image: "c29.jpg" },
  { name: "Pallavi Krishnan", handle: "pallavikrishnan", email: "pallavikrishnan@example.com", city: "Kochi", category: "Fitness", subcategory: "Yoga",
    theme: "luxury", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "Strength training in a 1BHK. Form over weight, always.", image: "c30.jpg" },
  { name: "Prisha Menon", handle: "prishamenon", email: "prishamenon@example.com", city: "Chandigarh", category: "Travel", subcategory: "Hill stations",
    theme: "adventure", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "Cheap routes, real budgets, and where to eat near the bus stand.", image: "c31.jpg" },
  { name: "Radhika Nayar", handle: "radhikanayar", email: "radhikanayar@example.com", city: "Indore", category: "Food", subcategory: "Street food",
    theme: "after_dark", layout: "editorial", pronouns: "she/they", bank: "oksbi", bio: "Recipes from my grandmother, written down before I forget them.", image: "c32.jpg" },
  { name: "Riya Pandit", handle: "riyapandit", email: "riyapandit@example.com", city: "Lucknow", category: "Lifestyle", subcategory: "Slow living",
    theme: "minimal", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "Small flat, fewer things, better mornings.", image: "c33.jpg" },
  { name: "Saanvi Raman", handle: "saanviraman", email: "saanviraman@example.com", city: "Goa", category: "Art & design", subcategory: "Ceramics",
    theme: "luxury", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "Everything here is made by hand. Slowly.", image: "c34.jpg" },
  { name: "Sanjana Saxena", handle: "sanjanasaxena", email: "sanjanasaxena@example.com", city: "Surat", category: "Music", subcategory: "Classical",
    theme: "adventure", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "Covers, riyaaz notes, and the mic I finally saved up for.", image: "c35.jpg" },
  { name: "Sara Thakur", handle: "sarathakur", email: "sarathakur@example.com", city: "Bhopal", category: "Gaming", subcategory: "Reviews",
    theme: "after_dark", layout: "gallery", pronouns: "she/they", bank: "paytm", bio: "Mobile first, because that is what most of us actually own.", image: "c36.jpg" },
  { name: "Shreya Varma", handle: "shreyavarma", email: "shreyavarma@example.com", city: "Nagpur", category: "Fashion", subcategory: "Thrift and second-hand",
    theme: "minimal", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "Thrift finds, what actually fits, and the tailor who saves everything.", image: "c37.jpg" },
  { name: "Simran Banerjee", handle: "simranbanerjee", email: "simranbanerjee@example.com", city: "Coimbatore", category: "Beauty", subcategory: "Makeup",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "Only the products I finished the bottle of. Oily skin, Indian weather.", image: "c38.jpg" },
  { name: "Sneha Chatterjee", handle: "snehachatterjee", email: "snehachatterjee@example.com", city: "Guwahati", category: "Fitness", subcategory: "Running",
    theme: "adventure", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "Strength training in a 1BHK. Form over weight, always.", image: "c39.jpg" },
  { name: "Tanvi Dixit", handle: "tanvidixit", email: "tanvidixit@example.com", city: "Dehradun", category: "Travel", subcategory: "Food trails",
    theme: "after_dark", layout: "classic", pronouns: "she/they", bank: "okicici", bio: "Cheap routes, real budgets, and where to eat near the bus stand.", image: "c40.jpg" },
  { name: "Tara Kaur", handle: "tarakaur", email: "tarakaur@example.com", city: "Mumbai", category: "Food", subcategory: "Home cooking",
    theme: "minimal", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "Recipes from my grandmother, written down before I forget them.", image: "c41.jpg" },
  { name: "Trisha Malhotra", handle: "trishamalhotra", email: "trishamalhotra@example.com", city: "Delhi", category: "Lifestyle", subcategory: "Organisation",
    theme: "luxury", layout: "gallery", pronouns: "she/her", bank: "paytm", bio: "Small flat, fewer things, better mornings.", image: "c42.jpg" },
  { name: "Vaishnavi Narayan", handle: "vaishnavinarayan", email: "vaishnavinarayan@example.com", city: "Bengaluru", category: "Art & design", subcategory: "Textile",
    theme: "adventure", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "Everything here is made by hand. Slowly.", image: "c43.jpg" },
  { name: "Vanya Patel", handle: "vanyapatel", email: "vanyapatel@example.com", city: "Chennai", category: "Music", subcategory: "Indie",
    theme: "after_dark", layout: "editorial", pronouns: "she/they", bank: "oksbi", bio: "Covers, riyaaz notes, and the mic I finally saved up for.", image: "c44.jpg" },
  { name: "Vedika Rathore", handle: "vedikarathore", email: "vedikarathore@example.com", city: "Hyderabad", category: "Gaming", subcategory: "Reviews",
    theme: "minimal", layout: "gallery", pronouns: "she/her", bank: "okhdfcbank", bio: "Mobile first, because that is what most of us actually own.", image: "c45.jpg" },
  { name: "Yamini Sen", handle: "yaminisen", email: "yaminisen@example.com", city: "Pune", category: "Fashion", subcategory: "Ethnic wear",
    theme: "luxury", layout: "classic", pronouns: "she/her", bank: "okicici", bio: "Thrift finds, what actually fits, and the tailor who saves everything.", image: "c46.jpg" },
  { name: "Zara Trivedi", handle: "zaratrivedi", email: "zaratrivedi@example.com", city: "Kolkata", category: "Beauty", subcategory: "Haircare",
    theme: "adventure", layout: "editorial", pronouns: "she/her", bank: "ybl", bio: "Only the products I finished the bottle of. Oily skin, Indian weather.", image: "c47.jpg" },
  { name: "Ritika Upadhyay", handle: "ritikaupadhyay", email: "ritikaupadhyay@example.com", city: "Ahmedabad", category: "Fitness", subcategory: "Home workouts",
    theme: "after_dark", layout: "gallery", pronouns: "she/they", bank: "paytm", bio: "Strength training in a 1BHK. Form over weight, always.", image: "c48.jpg" },
  { name: "Nandini Vora", handle: "nandinivora", email: "nandinivora@example.com", city: "Jaipur", category: "Travel", subcategory: "Budget travel",
    theme: "minimal", layout: "classic", pronouns: "she/her", bank: "okaxis", bio: "Cheap routes, real budgets, and where to eat near the bus stand.", image: "c49.jpg" },
  { name: "Diya Yadav", handle: "diyayadav", email: "diyayadav@example.com", city: "Kochi", category: "Food", subcategory: "Baking",
    theme: "luxury", layout: "editorial", pronouns: "she/her", bank: "oksbi", bio: "Recipes from my grandmother, written down before I forget them.", image: "c50.jpg" },
].freeze

# Per-category content, so a Fitness page does not recommend the same three
# things as a Baking page. [ collection name, [ [title, merchant, price, why] ] ]
CATEGORY_CONTENT = {
  "Fashion" => [ "What I am wearing", [
    [ "The white kurta that survives", "Myntra", "₹1,299", "Fourth summer in this one. Washes without going see-through, which is the whole ask." ],
    [ "Jeans that fit Indian hips", "Myntra", "₹2,199", "Stopped tailoring the waist on every pair I buy. That is the review." ],
    [ "Kolhapuris, resoled twice", "Myntra", "₹899", "Cheaper than the chappals I keep losing, and they get better with wear." ] ] ],
  "Beauty" => [ "Finished the bottle", [
    [ "The sunscreen that does not pill", "Nykaa", "₹649", "No white cast under a camera, no stinging, and it survives a Mumbai afternoon." ],
    [ "Cleanser for oily skin", "Nykaa", "₹390", "My skin stopped feeling tight after a week. Nothing else changed." ],
    [ "The lip balm, unscented", "Nykaa", "₹220", "Boring on purpose. Works." ] ] ],
  "Fitness" => [ "Kit that lasted", [
    [ "Resistance bands, set of five", "Decathlon", "₹799", "Replaced a gym membership for four months and I still use the heaviest one." ],
    [ "Yoga mat, 6mm", "Decathlon", "₹1,199", "Thick enough for a tiled floor, which is what most of us are actually on." ],
    [ "Adjustable dumbbells", "Decathlon", "₹4,499", "The only equipment that fits under a bed in a 1BHK." ] ] ],
  "Travel" => [ "What is in my bag", [
    [ "The 30L backpack", "Decathlon", "₹2,799", "Three days of clothes, a camera, and it still goes in the overhead." ],
    [ "Quick-dry towel", "Decathlon", "₹499", "Dries overnight in a humid room. Worth it for hostels." ],
    [ "Universal adapter", "Amazon", "₹749", "Used it in six countries and every Indian hotel with one working socket." ] ] ],
  "Food" => [ "My kitchen", [
    [ "The kadai I use daily", "Amazon", "₹1,450", "Cast iron, seasoned over two years, and it has replaced three other pans." ],
    [ "Weighing scale", "Amazon", "₹599", "Baking stopped being luck the day I got this." ],
    [ "Masala dabba, steel", "Amazon", "₹890", "Seven compartments, no plastic, and it does not hold smell." ] ] ],
  "Lifestyle" => [ "Small flat, fewer things", [
    [ "Storage baskets, set of three", "Sunday Home", "₹780", "The reason my desk is visible in any of my videos." ],
    [ "The softest throw", "Sunday Home", "₹2,499", "Bought it for the sofa, take it on every flight now." ],
    [ "Bedside lamp, warm", "Sunday Home", "₹1,150", "Stopped using the tube light at night and started sleeping properly." ] ] ],
  "Art & design" => [ "Tools I use", [
    [ "The sketchbook I finish", "Amazon", "₹450", "Paper takes a wash without buckling, which is rare at this price." ],
    [ "Trimming tools, cheap set", "Amazon", "₹640", "You do not need the expensive ones until you know what you are doing." ],
    [ "Brush set, synthetic", "Amazon", "₹380", "Six brushes, four of which I actually reach for." ] ] ],
  "Music" => [ "My setup", [
    [ "The mic I saved for", "Amazon", "₹6,999", "Recorded everything on this page with it, in a room with no treatment." ],
    [ "Closed-back headphones", "Amazon", "₹2,499", "No bleed into the mic, which is the only reason I own them." ],
    [ "Pop filter", "Amazon", "₹299", "Three hundred rupees between me and unusable takes." ] ] ],
  "Gaming" => [ "What I play on", [
    [ "The phone cooler", "Amazon", "₹1,299", "Two hours without thermal throttling. It genuinely works." ],
    [ "Trigger buttons", "Amazon", "₹249", "Cheap, plastic, and they changed my aim more than any setting." ],
    [ "Power bank, 20000mAh", "Amazon", "₹1,899", "Streams a full session and charges my phone twice." ] ] ]
}.freeze

# A handful rename their sections, so the editable-heading path is covered by
# real data rather than only by an empty settings form.
CUSTOM_HEADINGS = {
  "Fashion"      => { links_heading: "What I am actually wearing", media_heading: "The outtakes" },
  "Food"         => { links_heading: "In my kitchen", posts_heading: "Cooking notes" },
  "Art & design" => { links_heading: "Tools I reach for", media_heading: "Work in progress" },
  "Music"        => { media_heading: "Unreleased", posts_heading: "Riyaaz notes" },
  "Fitness"      => { links_heading: "Kit that lasted", meet_heading: "Train with me" }
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
    post = creator.paid_media_posts.find_or_initialize_by(title: "The full set, unedited")
    post.assign_attributes(caption: "Everything from the last shoot.",
      price_cents: [ 19_900, 29_900, 49_900 ][i % 3], currency: "INR",
      media_type: "image", published: true)
    attach_image(post, :media, "creators/#{row[:image]}")
    attach_image(post, :preview, "creators/#{row[:image]}")
    post.save!
  end

  if (i % 4).zero?
    reveal = creator.contact_reveals.find_or_initialize_by(label: "My WhatsApp, brand enquiries only")
    reveal.assign_attributes(secret_value: "+91 9#{(800_000_000 + i * 7919)}"[0, 15],
      price_cents: 19_900, currency: "INR", published: true)
    reveal.save!
  end

  if (i % 5).zero?
    wl = creator.wishlists.find_or_initialize_by(title: "Setup fund")
    wl.assign_attributes(description: "Saving towards gear that would change what I can make.", published: true)
    wl.save!
    it = wl.wishlist_items.find_or_initialize_by(title: "The upgrade I keep putting off")
    it.assign_attributes(target_cents: (15 + i) * 100_000, currency: "INR",
      note: "Been borrowing one for a year.")
    it.save!
  end

  if (i % 2).zero?
    body = "#{[ "Shot something new today.", "Two questions in my DMs all week, so answering here.", "Restocked the thing everyone asked about." ][i % 3]} More soon."
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
