# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the Next.js fan PWA.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:3000", "http://localhost:3001", "https://app.wishful.in", "https://wishful.in"

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization Content-Type],
      credentials: true

    resource "/cable",
      headers: :any,
      methods: %i[get post options],
      credentials: true
  end
end
