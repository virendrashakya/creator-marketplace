# Wishful — Comprehensive Platform & Technical Reference

> **Instructions for Developers & AI Models:**
> This document is the single source of truth for the **Wishful** creator platform. You can copy-paste the snippet below or this entire document into any LLM prompt/chat to instantly provide full architectural and business context.
>
> **Maintenance Rule:** Always update this file, `FEATURES.md`, and `TODO.md` whenever models, routes, features, services, or architecture are modified. Keep documentation in lockstep with the codebase.

---

```markdown
<!-- QUICK LLM CONTEXT SNIPPET: COPY FROM HERE -->
## PROJECT CONTEXT: Wishful (Creator Monetization Platform)
- What it is: A high-converting, direct-to-creator monetization platform purpose-built for the Indian creator economy (glamour, saree modeling, short-form reels creators, GRWM, fashion & lifestyle).
- Core Value Proposition: 100% creator earnings with 0% platform rake via peer-to-peer direct UPI (GPay, PhonePe, Paytm, BHIM) and manual 12-digit UTR reconciliation.
- Tech Stack: Ruby on Rails 8 (Ruby 3.4.4), Hotwire (Turbo & Stimulus), Vanilla CSS design system (5 themes, 3 layouts), ActionCable WebSockets (Solid Cable), Solid Queue, Solid Cache, ActiveStorage, ImageMagick.
- Key Capabilities:
  1. The Vault (PPV 4K photo & video sets, bundles, paywalls).
  2. Server-side Anti-Leak DRM: Irreversible blurred teaser previews (FrostedPreviewService) + dynamic visible/EXIF forensic watermarking with fan handle/ID (ForensicWatermarkService) + transparent client-side overlay shields (.media-shield).
  3. Close Friends & VIP Subscriptions: Recurring monthly passes that auto-unlock the Vault.
  4. Direct Contact & Secret Reveals: Paid unlocks for private WhatsApp VIP groups, Telegram channels, or personal contact.
  5. 1:1 Private DMs & PPV Chat: Real-time messaging with locked media cards.
  6. 1:1 Bookings & Live Broadcasts: Calendar time-slot scheduling (MeetOffer) + subscriber-gated live rooms with real-time chat.
  7. Wishlists & Gifting ("Spoil Me"): Crowd-funded or single-buyer gifts with progress meters.
  8. Curated Affiliate Recommendations: Lookbooks and equipment with referral click-tracking.
  9. Viral Sharing Engine: WhatsApp/Telegram OpenGraph unfurling with frosted thumbnails and referral tokens.
<!-- QUICK LLM CONTEXT SNIPPET: END COPY -->
```

---

## 1. Executive Summary & Vision

### What is Wishful?
**Wishful** is an all-in-one creator storefront, subscription hub, and exclusive media delivery engine designed specifically for South Asian creators (models, fashion influencers, reels creators, saree draping artists, GRWM stylists).

### Why Was It Built?
1. **Payment Friction in India**: Western platforms (OnlyFans, Patreon, Fanfix) rely on international credit cards with high rejection rates (RBI 2FA mandates), enforce 20–30% platform cuts, and face banking restrictions. Wishful uses **direct UPI** (GPay, PhonePe, Paytm, BHIM), allowing instant INR transfers directly into creator bank accounts with zero intermediary fees.
2. **Content Leakage & Scraping**: Traditional creator sites suffer from widespread scraping and anonymous leaks to Telegram, Reddit, and cyber-lockers. Wishful implements a multi-tiered **anti-leak security architecture** that strips raw files from the network and forensically brands unlocked media with the buyer's unique digital signature.
3. **Mobile-First & Aesthetics**: Designed for mobile viewers coming from Instagram Reels, TikTok, and YouTube Shorts, featuring rich visual themes (Minimal, Luxury, Adventure, After Dark, Atelier) and editorial layouts.

---

## 2. Core Feature Specifications

### 2.1 The Vault (Pay-Per-View Drops & Bundles)
- **Model**: `PaidMediaPost`, `PaidMediaCollection`, `MediaPurchase`
- **Pricing**: Expressed in paise / INR (`price_cents`, e.g., ₹99, ₹199, ₹499, ₹999).
- **Media Types**: High-res multi-photo sets and 4K video teasers.
- **Access Check**: `post.unlocked_for?(user)` returns true if:
  1. The viewer is the post's author/creator.
  2. The viewer has a confirmed `MediaPurchase`.
  3. The viewer holds an active VIP `CreatorSubscription` to the creator's plan.
- **Teaser States**: Frosted lock card UI displaying price pill, VIP Vault badge, and preview thumbnail. Once unlocked, seamlessly updates to full-resolution viewing with an `✨ Unlocked & Yours` badge.

### 2.2 Content Security & Anti-Leak DRM Shield
- **Server-Side Frosted Previews (`FrostedPreviewService`)**:
  - ImageMagick downsamples images to 80x80 (`-resize 80x80^`) to destroy facial and fine details, then applies Gaussian blur (`-gaussian-blur 0x16`).
  - Raw unblurred image bytes are **never** served over HTTP to unauthenticated visitors or scrapers.
  - Cached to disk in `tmp/cache/frosted_previews/#{blob.key}.jpg` with HTTP `ETag` and `Cache-Control: public, max-age=86400` (sub-15ms response).
- **Dynamic Forensic Watermarking (`ForensicWatermarkService`)**:
  - Unlocked downloads are dynamically watermarked on the server based on the logged-in viewer's identity:
    - **Diagonal Center Stamp**: `@fan_handle • #fan_id` faintly etched across the subject (`rgba(255,255,255,0.18)`), defeating edge crops.
    - **Footer Attribution Banner**: High-contrast banner: `Licensed to @fan_handle (Fan #fan_id) • Wishful • YYYY-MM-DD`.
    - **EXIF Metadata**: Licensee identity and timestamp injected into binary JPEG metadata.
  - **Creator Exemption**: The creator downloading their own media receives 100% pristine, unwatermarked originals.
  - Leakers lose plausible deniability; redistributed content identifies the leaking account immediately.
- **Client-Side Anti-Theft Protection**:
  - Transparent overlay element (`.media-shield`) sitting over images intercepting mouse/pointer events.
  - `draggable="false"`, `oncontextmenu="return false;"`, and `pointer-events: none` block right-click saving and drag-to-desktop gestures.

### 2.3 Direct UPI Settlement & Payment Verification
- **Model**: `PaymentClaim`
- **Flow**:
  1. Fan clicks to unlock a Vault drop, VIP subscription, meet slot, secret reveal, or wishlist gift.
  2. App displays the creator's personalized UPI QR code and UPI ID (`yourname@bank`).
  3. Fan pays using GPay, PhonePe, Paytm, or BHIM.
  4. Fan submits the 12-digit bank reference number (**UTR**) and optional screenshot on the claim screen.
  5. Claim enters the creator's **Payment Review Queue** (`/payment_claims`).
  6. Creator approves the claim, which executes `PaymentClaim#approve!` -> `PaymentFulfillment.grant!` to instantly grant the purchase or subscription.
  7. **Mismatch Warning System**: Flags claims where the reported amount does not match the product price.

### 2.4 Close Friends & VIP Subscriptions
- **Model**: `SubscriptionPlan`, `CreatorSubscription`
- **Features**: Monthly recurring passes (e.g., ₹299/mo, ₹499/mo).
- **Benefits**: Automatic access to all published Vault drops, priority DM status, glowing subscriber badge, and access to subscribers-only live broadcasts.

### 2.5 Direct Contact & Channel Reveals
- **Model**: `ContactReveal`, `AccessPurchase`
- **Features**: Pay-to-reveal secret links and personal contact information (VIP Close Friends WhatsApp link, private Telegram channel, Discord pass, personal number).
- **Security**: The secret value is encrypted at rest and never transmitted to the browser until an `AccessPurchase` is verified.

### 2.6 Private 1:1 Direct Messaging & PPV Chat
- **Model**: `Conversation`, `DirectMessage`
- **Technology**: Real-time bidirectional WebSockets powered by ActionCable (`/cable`).
- **Features**: 1:1 creator-fan chat, unread counters, notification indicators, and optional PPV locked attachments inside chat bubbles.

### 2.7 1:1 Time Bookings & Live Broadcasts
- **Model**: `MeetOffer`, `MeetSlot`, `LiveSession`, `LiveMessage`
- **1:1 Video Calls**: Creators create offers with durations and prices. Fixed time slots (`MeetSlot`) are bookable by fans.
- **Live Broadcasts**:
  - Public lobby with VIP gating: Any user can open the stream page, but viewing the live broadcast is gated on an active subscription.
  - Creator studio controls (`/lives/:id/studio`) to start, broadcast, and finish sessions.
  - Real-time interactive live chat powered by ActionCable.
- **Unified Schedule**: Both meetups and scheduled live sessions appear on the unified `/schedule` calendar.

### 2.8 Wishlist & Gifting ("Spoil Me")
- **Model**: `Wishlist`, `WishlistItem`, `GiftContribution`
- **Features**: Creators list items (dresses, camera gear, perfumes, spa days) with target amounts in paise.
- **States**: Progress bar reflects funding status (empty, partially funded, fully funded). Supports both full gifts and pooled contributions.

### 2.9 Curated Recommendations & Affiliate Collections
- **Model**: `ProductLink`, `LinkCollection`, `LinkClick`
- **Features**: Handpicked outfits, makeup, saree accessories, and equipment.
- **Analytics**: Click tracking via `/go/:id` redirector with counter caching (`clicks_count`) and referrer tracking.

### 2.10 Viral Social Sharing Engine
- **Dynamic OpenGraph Meta Tags**: When shared into WhatsApp, Telegram, or Twitter, generates rich unfurl cards with drop title, creator name, price, and the **backend-frosted teaser thumbnail**.
- **Referral Tracking**: Links append `?ref=username` to credit fans who refer new paying subscribers.
- **Contextual Welcome Banners**: Highlights who shared the drop when a new visitor lands on the site.

---

## 3. Technology Stack & Infrastructure

| Layer | Technology | Details |
|---|---|---|
| **Language & Runtime** | Ruby 3.4.4 | Managed via RVM / system package |
| **Framework** | Rails 8.0.2 | Standard omakase Rails stack |
| **Database** | PostgreSQL / SQLite | Solid Cable, Solid Queue, Solid Cache |
| **Frontend UI** | Hotwire (Turbo + Stimulus) | Zero SPA overhead, reactive DOM replacement |
| **Styling** | Vanilla CSS Design System | Custom tokens in `public/assets/profile.css`, `dashboard.css`, etc. |
| **Real-Time** | ActionCable WebSockets | Mounted at `/cable` for DMs and live broadcast chat |
| **File Storage** | ActiveStorage | Backed by local disk in dev, S3/GCS compatible in prod |
| **Image Processing** | ImageMagick (`convert`) | Used by `FrostedPreviewService` and `ForensicWatermarkService` |
| **Security & DRM** | Custom Services | Server-side blur, dynamic forensic watermark, `.media-shield` |

---

## 4. Theme & Layout Design System

Creators can customize their public presence without breaking the underlying layout:

### Themes (`User::THEMES`)
1. **Minimal (`minimal`)**: Clean alabaster surfaces (`#F4F5F3`), crisp editorial typography, ruby accents (`#C2185B`).
2. **Luxury (`luxury`)**: Deep midnight violet background (`#14142A`), warm blush highlights (`#F0A9C8`), champagne gold borders.
3. **Adventure (`adventure`)**: Soft sage background (`#EDF1EA`), deep forest green accents (`#0B5B42`).
4. **After Dark (`after_dark`)**: Jet black canvas (`#0C0D10`), neon pink glow (`#FF5C8A`), high-contrast night aesthetics.
5. **Atelier (`atelier`)**: Minimal monochrome obsidian (`#050505`), hot magenta highlight (`#E91E63`).

### Layouts (`User::LAYOUTS`)
1. **Classic (`classic`)**: Vertical list flow; optimal for link-in-bio style pages and product-heavy curators.
2. **Editorial (`editorial`)**: Magazine cover layout with prominent banner, spotlight cards, and tabbed showcase.
3. **Gallery (`gallery`)**: Visual-first masonry grid prioritizing photo and video drops over text links.

---

## 5. Domain Model & Database Schema

```
User (creators & fans)
 ├── has_many :paid_media_posts
 ├── has_many :paid_media_collections
 ├── has_many :media_purchases (as buyer)
 ├── has_many :subscription_plans
 ├── has_many :creator_subscriptions (as subscriber)
 ├── has_many :access_purchases (as buyer)
 ├── has_many :contact_reveals
 ├── has_many :meet_offers ── has_many :meet_slots
 ├── has_many :wishlists ── has_many :wishlist_items ── has_many :gift_contributions
 ├── has_many :creator_posts ── has_many :creator_post_likes, :creator_post_comments
 ├── has_many :live_sessions ── has_many :live_messages
 ├── has_many :creator_conversations / fan_conversations ── has_many :direct_messages
 ├── has_many :payment_claims (as claimant & received)
 ├── has_many :link_collections ── has_many :product_links ── has_many :link_clicks
 ├── has_many :follower_relationships / following_relationships
 └── attachments: :profile_picture, :banner, :upi_qr
```

---

## 6. Key Application Routes

| Path | Controller#Action | Purpose |
|---|---|---|
| `GET /` | `pages#home` | Platform landing page & creator discovery |
| `GET /:handle` | `profiles#show` | Public creator storefront (tabbed: Vault, Fits, Wishlist, DMs) |
| `GET /dashboard` | `dashboard#show` | Creator analytics, link manager, collection manager |
| `GET /creator_settings` | `creator_settings#edit` | Theme, layout, UPI ID, bio, and social handles |
| `GET /pay/:type/:id` | `payment_claims#new` | UPI QR payment & UTR submission screen |
| `POST /pay/:type/:id` | `payment_claims#create` | Create a new payment claim with 12-digit UTR |
| `GET /payment_claims` | `payment_claims#index` | Creator payment review queue (approve/reject) |
| `GET /paid_media_posts/:id/media` | `paid_media_posts#media` | Serves unlocked, dynamically watermarked high-res media |
| `GET /paid_media_posts/:id/preview` | `paid_media_posts#preview` | Serves server-side frosted teaser preview |
| `GET /conversations` | `conversations#index` | 1:1 Direct Message inbox |
| `GET /conversations/:id` | `conversations#show` | Active chat room with real-time WebSocket updates |
| `GET /lives/:id` | `live_sessions#show` | Subscriber-gated live stream viewer room |
| `GET /lives/:id/studio` | `live_sessions#studio` | Creator broadcast management studio |
| `GET /schedule` | `schedule#show` | Unified calendar for 1:1 meets & live sessions |
| `GET /go/:id` | `product_links#visit` | Redirector for affiliate recommendations with click logging |

---

## 7. Development & Testing Reference

- **Default Test Password**: `password123` across all seeded users in development.
- **Flagship Demo Creator**:
  - Email: `ananya@example.com`
  - Handle: `@ananyarao`
  - URL: `http://127.0.0.1:3000/@ananyarao`
  - Persona: 32 | Mumbai saree draper, editorial model & GRWM reels creator.
- **Seed Script**: Run via `bin/rails db:seed`. Populates 50 realistic Indian creator profiles across 5 distinct lifestyle and fashion categories.
- **Environment Notes**:
  - Always run Rails with Ruby 3.4.4 (e.g. `~/.rvm/wrappers/ruby-3.4.4/bundle exec ...`).
  - ActiveStorage uses `local` disk service in development with uploaded assets under `storage/`.
