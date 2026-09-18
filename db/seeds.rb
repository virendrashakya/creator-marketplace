# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

demo = User.find_or_initialize_by(email: "mira@example.com")
demo.assign_attributes(name: "Mira Patel", handle: "miraedits", password: "password123", password_confirmation: "password123", bio: "Little things I’m loving lately ✦")
demo.save!

beauty = demo.link_collections.find_or_create_by!(name: "Beauty favourites")
home = demo.link_collections.find_or_create_by!(name: "Home finds")
demo.product_links.find_or_create_by!(title: "Daily glow serum") { |link| link.url = "https://example.com/glow-serum"; link.merchant = "Studio Skin"; link.price = "₹1,890"; link.link_collection = beauty; link.featured = true }
demo.product_links.find_or_create_by!(title: "The softest throw") { |link| link.url = "https://example.com/throw"; link.merchant = "Sunday Home"; link.price = "₹2,499"; link.link_collection = home }

# The vouch row leads with the creator's reason, so demo links need one: a
# recommendation with an empty description renders as a bare product name and
# does not show what the page is for.
{
  "Daily glow serum" => "Three weeks in and the patch on my chin that never settles has finally calmed down.",
  "The softest throw" => "Bought it for the sofa, ended up taking it on every flight since."
}.each do |title, reason|
  link = demo.product_links.find_by(title: title)
  link&.update!(description: reason) if link && link.description.blank?
end

# A second creator so the profile themes and the paid flows are visible in
# development. Everything below is idempotent.
raya = User.find_or_initialize_by(email: "raya@example.com")
raya.assign_attributes(
  name: "Raya Dsouza", handle: "rayamakes",
  password: "password123", password_confirmation: "password123",
  bio: "Ceramics, slow mornings, and the tools I actually reach for.",
  theme: "luxury", profile_layout: "editorial",
  location: "Goa", pronouns: "she/her", creator_category: "Art & design",
  accepts_upi_manual: true, upi_id: "raya@okaxis", upi_payee_name: "Raya Dsouza"
)
raya.save!

raya.product_links.find_or_create_by!(title: "The wheel I learned on") do |link|
  link.url = "https://example.com/wheel"
  link.merchant = "Shimpo"
  link.price = "₹68,000"
  link.description = "Heavy enough that it does not walk across the floor when I centre badly."
  link.featured = true
end

raya.contact_reveals.find_or_create_by!(label: "My studio WhatsApp") do |reveal|
  reveal.secret_value = "+91 98765 43210"
  reveal.price_cents = 49_900
  reveal.currency = "INR"
  reveal.published = true
end

offer = raya.meet_offers.find_or_create_by!(title: "Throw a bowl with me") do |o|
  o.description = "Two hours at the wheel. Clay and firing included."
  o.location = "Assagao, Goa"
  o.price_cents = 2_50_000
  o.currency = "INR"
  o.duration_minutes = 120
  o.published = true
end
if offer.meet_slots.empty?
  offer.meet_slots.create!(starts_at: 6.days.from_now.change(hour: 10), ends_at: 6.days.from_now.change(hour: 12))
  offer.meet_slots.create!(starts_at: 9.days.from_now.change(hour: 15), ends_at: 9.days.from_now.change(hour: 17))
end

list = raya.wishlists.find_or_create_by!(title: "Kiln fund") do |w|
  w.description = "Saving for a kiln that fits more than six pieces."
  w.published = true
end
list.wishlist_items.find_or_create_by!(title: "Front-loading kiln") do |item|
  item.target_cents = 1_20_000_00
  item.currency = "INR"
  item.note = "The one that would let me fire a whole dinner set at once."
  item.status = "available"
end
