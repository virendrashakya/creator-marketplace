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
