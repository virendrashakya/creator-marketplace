# Wishful — Comprehensive Platform & Technical Reference

> **Instructions for Developers & AI Models:**
> This document is the single source of truth for the **Wishful** creator platform. You can copy-paste the snippet below or this entire document into any LLM prompt/chat to instantly provide full architectural and business context.
>
> **Maintenance Rule:** Always update this file, `FEATURES.md`, and `TODO.md` whenever models, routes, features, services, or architecture are modified. Keep documentation in lockstep with the codebase.
>
> **Last major change:** 13 Oct 2026, the dark "Studio" redesign (Claude Design files: Fan App, Creator Dashboard, Link Lists, Onboarding, PWA and States). Screenshots: `docs/screenshots/redesign-2026-10/`.

---

```markdown
<!-- QUICK LLM CONTEXT SNIPPET: COPY FROM HERE -->
## PROJECT CONTEXT: Wishful (Creator Monetization Platform)
- What it is: A mobile-first storefront, creator Studio, and Next.js + Workbox PWA where Indian creators (saree drapers, glamour & fashion models, GRWM and reels creators) get paid directly by fans.
- Core Value Proposition: 100% creator earnings, 0% platform rake. Fans pay the creator's own UPI ID (GPay, PhonePe, Paytm, BHIM) and submit the 12-digit UTR; the creator approves it and the unlock is granted.
- Tech Stack:
  - Backend & Studio: Ruby on Rails 8.0 (Ruby 3.4.4), PostgreSQL, Turbo Drive, vanilla JS, ActionCable (Solid Cable), Solid Queue/Cache, ActiveStorage, ImageMagick, rqrcode, web-push, jwt, rack-cors.
  - Fan PWA (`fan-app/`): Next.js 16 (React 19, TypeScript), Workbox service worker caching unlocked media and APIs, offline mode, standalone web manifest.
- Database & Analytics Architecture (Scalable Event Sourcing):
  - `events`: Partitioned monthly (range partitioning) capturing every view, like, comment, follow, unlock, and gift.
  - Daily Rollups: `creator_daily_stats`, `content_daily_stats`, `referral_daily_stats` aggregated nightly.
  - Engagement Scoring: `fan_profiles` with composite score (spend, unlocks, CF months, likes, comments, shares, live watches) and tiers (whale, super_fan, regular, casual, lurker).
  - Feed & Fan-Out: `feed_items` populated on write via `FeedFanoutJob` for instant reverse-chronological fan timelines.
  - Counter Caches: Real-time counter caches on `users`, `paid_media_collections`, `paid_media_posts`, `creator_posts`, and `link_lists`.
  - Notifications & Auth: `notifications` in-app inbox and `user_sessions` with JWT authentication.
- Design: Obsidian Velvet & Neon Ruby (`public/assets/wf.css` and `fan-app/src/app/globals.css`): pure abyss #050406 canvas, smoked velvet #0E0C12 cards with hairline ruby borders, electric ruby #FF1767 action gradient (linear-gradient(135deg, #ff1767, #c026d3)) with radiant neon bloom, gold #F5B942 for Close Friends and "yours", green #4ADE80 for money in. Plus Jakarta Sans with extreme weight contrasts and full pill silhouettes.
- Key Capabilities:
  1. Fan Feed (`/feed`): Timeline of followed creators' Vault album drops, posts, and live streams with instant unlock CTA buttons.
  2. Explore & Drops (`/discover`): Trending collections, creator categories, and upcoming live broadcasts.
  3. Storefront `/:handle`: Creator's public website & link in bio with Posts, Collections, Shop, and Book tabs.
  4. Collections: Public cover, locked items teased, instant pay sheet with 12-digit UPI claim.
  5. Close Friends: VIP subscription pass unlocking member collections, lives, and priority DMs.
  6. DRM: `FrostedPreviewService` (server blur) + `ForensicWatermarkService` (buyer ID burned in) + in-viewer overlay.
<!-- QUICK LLM CONTEXT SNIPPET: END COPY -->
```

---

## 1. Executive Summary

**Wishful** is a creator storefront, Close Friends hub and protected media delivery engine for South Asian creators. Western platforms rely on cards (high failure rates under RBI 2FA) and take 20–30%. Wishful routes every rupee peer-to-peer over UPI, and protects what fans buy with server-side blurring and per-buyer forensic watermarks.

The October 2026 redesign moved the product to a single dark visual system and a collection-centric model: free posts bring fans in, paid work lives in collections, and the creator runs everything from Studio.

---

## 2. Feature Specifications

### 2.1 Storefront (`/:handle`, `ProfilesController#show`)
- Header: handle with verified tick, share; avatar with pink/gold ring; posts · fans · collections counts; name, category, city, bio.
- Actions: Follow / Message / Spoil Me gift (fans), Edit profile / New post (owner).
- Highlights row: VIP (Close Friends), Lives, each on-profile link list, Spoil me, Book.
- Tabs (`?tab=posts|collections|shop|book`, old names aliased): Posts grid (free), Collections (cover + lock count + "Yours"), Shop (chips by `LinkCollection`, affiliate cards via `/go/:id`), Book (meet offers with slot picker, upcoming lives, contact reveals as Paid DM / WhatsApp circle).
- Floating Close Friends bar; PWA install prompt for visitors.
- Desktop (≥900px): magazine header (150px avatar left), 4-column grids.
- Empty states for a new creator (post / collection / shop / book).

### 2.2 Collections (`PaidMediaCollection`)
- Ordered items (`PaidMediaPost.position`); **the first item is the public cover** and is served unblurred to everyone via `/paid_media_posts/:id/media` (`PaidMediaPost#collection_cover?`, only once the collection is released).
- `price_cents` and/or `subscription_plan` (Close Friends). A collection must have at least one (`sellable` validation).
- `release_at` schedules a drop (`PaidMediaCollection.live` = published and released). `allow_downloads` offers a watermarked download in the viewer.
- `unlocked_for?(user)`: owner, a paid `AccessPurchase`, or an active subscription to its plan. `PaidMediaPost#unlocked_for?` also honours collection access.
- Fan pages: `/:handle/c/:id` (cover, hidden-count tiles, one price, one button, Close Friends alternative, pending-claim state) and `/:handle/c/:id/view?i=N` (full-screen viewer, diagonal `@handle · ID` overlay, progress, thumbnails).
- Standalone drops (posts with no collection) still sell on their own at `/:handle/d/:id`.
- Studio: `/paid_media_collections` grid (status, unlocks, revenue), `/paid_media_collections/:id/edit` editor (multi-file upload, drag reorder, price in rupees, release, Close Friends / downloads / show-on-profile switches).

### 2.3 Paying (`PaymentClaim`)
1. Fan opens `/pay/:type/:id` (signed out → `/join`, phone + handle + WhatsApp OTP, then straight back).
2. Pay sheet: GPay / PhonePe / Paytm / BHIM deep links (`tez://`, `phonepe://`, `paytmmp://`, `upi://`), UPI ID copy, QR (uploaded or generated with rqrcode), optional screenshot, optional "paid a different amount" and note.
3. UTR (shown in groups of four, stored as digits). Reused UTRs are rejected with the 10c message; DB unique index per creator remains the backstop.
4. Claim saved → `Notifier.claim_created` (Web Push + optional WhatsApp to creator) or, if the creator opted in and it is an exact match under their limit, auto-approved.
5. Fan lands on `/payment_claims/:id`: timeline (paid, UTR sent, creator checking, unlocked), auto-refresh every 15s, push opt-in card. Approved → "Open it now"; rejected → 10b error screen with "Fix UTR and resend".
6. Creator: `/payment_claims` (Payments) with Waiting/Approved/Rejected/All, stats, CSV export, Approve / Reject / "Ask ₹N" (opens a DM asking for the shortfall, `#nudge`).
- `PaymentClaim#approve!` → `PaymentFulfillment#grant!` → `Notifier.claim_approved`. `link_list_id` records which list the fan came from.

### 2.4 Close Friends (`SubscriptionPlan`, `CreatorSubscription`)
- `/:handle/close-friends`: perks, plan picker, "Continue to UPI". One month per payment, no auto-debit; renewing early extends from the current expiry.
- `User#close_friends_plan` (cheapest active plan) is what the storefront sells; collections opt in from the editor.

### 2.5 Link lists (`LinkList`, `LinkListItem`)
- Public page `/:handle/:slug`: cover hero, socials chosen per list, rows (product, video, collection with price pill), "From my blog" block for URLs under the creator's `blog_url`, "More from" card. Desktop floats over a blurred copy of the cover.
- Item kinds: `url`, `product_link` (a Shop item), `collection`. Taps go through `/l/:id` (counts `clicks_count`, re-checks the URL is public http(s)); collection taps carry `?list=` into the pay flow for attribution.
- Studio: `/lists` (opens, taps, earned, live/hidden/off), `/lists/:id/edit` (cover, title, description, socials toggles, paste link, + My collection, + From Shop, drag reorder, inline item edit, phone preview iframe, Copy / WhatsApp / Story / QR (SVG download) / Bio link, show-on-profile and on/off switches).
- Hidden lists still open by link; an "off" list 404s for everyone but its owner.

### 2.6 Accounts & onboarding
- `OtpCode`: 6 digits, HMAC digest only, 10-minute TTL, 5 attempts, 30-second resend throttle.
- `OtpController`: one flow, three intents (creator, sign_in, fan); intent and phone live in the session between send and verify.
- `WhatsappClient`: WhatsApp Cloud API template sends. Without `WHATSAPP_TOKEN`/`WHATSAPP_PHONE_NUMBER_ID`/`WHATSAPP_OTP_TEMPLATE` it logs the code (and flashes it in development).
- Creator onboarding (`OnboardingController`): `/start` phone → OTP → `/start/profile` handle, name, categories → `/start/upi` UPI ID + payee name → `/start/live` copy link, first collection.
- Email + password still works at `/sign_in/email`; `/sign_up` forwards to `/start`.
- `User.email` is optional when `phone_number` (E.164, unique) is present.

### 2.7 Studio (creator web app, `layout chrome = "studio"`)
Sidebar: Overview, Posts, Collections, Shop, Link lists, Book, Payments (pending count), Messages (unread count), Settings.
- **Overview** `/dashboard`: earned this month vs last, collection unlocks, Close Friends members and monthly value, link-list opens/taps; earnings chart (7D/30D/90D) split by Collections / Close Friends / Tips & gifts / Calls & access; "Needs you" (claims, next live, unread, next call); top collections.
- **Content & Posts** `/creator_posts` (+ `/new`, `/edit`, `.csv`): Atelier Pro Content & Post Inventory suite with 5 real-time KPI cards (Total Posts, Impressions, PPV Sales, Conversion Rate, Retention), segmented filter tabs (All, PPV Drops, Video/4K Reels, Photo Sets, Audio Whispers, Collections), status/sort controls, administrative inventory table with high-res media previews and CTR/revenue metrics, 3 strategy insight cards, CSV audit export, and `+ Create New Asset` 4-flow trigger modal. Dedicated Create Post Studio composer (`/creator_posts/new`) featuring 5 archetype switchers (Text & Story, Photo Set, 4K Reel, Audio Whisper, Interactive Poll), rich formatting toolbar, lossless media asset tray (up to 4GB RAW/DNG/ProRes), interactive community poll setup, wardrobe & sourcing tags (`W-01`/`W-02`), organic collection purchase card link, access & cadence controls (visibility, timing, pin, whisper alert, dynamic watermark), audience projections, and feed preview modal.
- **Shop** `/product_links`: affiliate links with taps, categories (`LinkCollection`).
- **Book** `/schedule`: week calendar (calls, lives, open slots) + "What fans can book" switches for meet offers and contact reveals.
- **Messages & VIP Desk** `/conversations` (and `/conversations/:id`): Obsidian Velvet & Neon Ruby 3-pane creator messaging suite (`app/views/conversations/studio.html.erb` for creators, mobile-first `index.html.erb` for fans):
  1. *Left Pane (Inbox & VIP Desk)*: VIP Desk badge, `+ Broadcast` action, filter tabs (`All (24)`, `VIP (18)`, `DMs (6)`, `Unread (3)` with electric ruby pill), real-time thread search, conversation cards with avatar initials/presence dots, patron handles with gold star badges, VIP indicators (`TOP 0.1%`, `₹500 TIP`, `PATRON • VIP PASS`, `BROADCAST • 184 PATRONS`), snippet previews, relative timestamps, and bottom P2P instant gateway status strip (`0% Platform Cut`).
  2. *Center Pane (Active Conversation Thread & VIP Actions)*: Patron status bar (`@kabir_x`, `● Online Now`, `Last Tip: ₹500`, Direct UPI verified badge), quick action buttons (`Send Vault Teaser`, `Request Tip`, profile inspection, more options), E2E encryption + Forensic Watermark token notice (`kabir@oksbi`), date separator, attached UPI tip card (`₹500 Direct UPI Tip attached`, `SETTLED` badge, transaction ref), patron chat bubbles, creator Studio Voice Note card (Audio Whisper waveform with play toggle and 0:48s duration), Midnight Silk Exclusive Drop card (attached PPV vault drop with cover thumbnail, ₹499 price tag, `CLAIMED BY PATRON` badge, and dynamic watermark notice), quick creator action bar (`Photo / Video`, `Attach Vault PPV`, `Audio Whisper`, `UPI Request`, `Quick Replies`), and rounded composer with emoji picker and glowing ruby send button.
  3. *Right Drawer (Fan About & Patron Intel)*: Toggled on-demand via the three-dot (`more_vert`) menu in the chat header (keeps the main conversation view completely uncluttered by default), with a dedicated close button: displays patron location (`Bandra West, Mumbai`), tier pill (`Tier 3 VIP / Inner Circle`), total Direct UPI volume bento card (`₹18,450`, `100% P2P settled • Zero middleman`), verified UPI address matched to Bank KYC (`kabir@oksbi`), quick creator actions (`Send Private Vault Drop`, `Create 1:1 Booking Slot`, `Custom Price Quote`), and recent patron activity feed.
- **Settings** `/creator_settings`: profile, socials (incl. blog), UPI payouts (UPI ID, payee name, backup UPI, QR upload, auto-approve under ₹N, WhatsApp me for new claims), Close Friends plans, Spoil Me lists, account (phone, email, blocked accounts, push).
- Older create/edit forms (meet offers, plans, wishlists, reveals, lives) render inside Studio; `wf.css` re-points the old stylesheet's tokens so they come out dark.

### 2.8 Fan app screens
- `/unlocks` (PWA start page): pending claims, unlocked collections and drops (with "Saved" when cached offline), Close Friends memberships.
- DMs `/conversations/:id` (phone chat, paid media cards with "Unlock ₹N", ₹ gift button).
- Lives `/lives/:id`: full-screen room, gated on `watchable_by?`, chat over ActionCable, ₹ Gift → Spoil Me. Creator phone studio `/lives/:id/studio`: go live / end, chat, share link, room controls sheet.
- Spoil Me `/:handle/spoil-me`: gift card, progress, who chipped in, ₹101/₹501/₹1,001 or any amount → pay sheet.

### 2.9 PWA
- `app/views/pwa/manifest.json.erb` (start_url `/unlocks`, icons `public/icon-192.png`, `icon-512.png`, `icon-maskable.png`, `icon.svg`).
- `app/views/pwa/service-worker.js`: network-first pages with offline fallback (`/offline`), cached shell assets, `wf-unlocks` cache of watermarked media for offline viewing (cleared on sign-out), push display and click routing.
- `wf.js`: SW registration, install banner (Android prompt, iOS Share-sheet hint), push subscribe (`POST /push_subscriptions`).
- `WebPushNotifier`: VAPID from `VAPID_PUBLIC_KEY`/`VAPID_PRIVATE_KEY`; in development a pair is generated into `storage/vapid.json`.

### 2.10 Content security
- `FrostedPreviewService`: ImageMagick downsample + Gaussian blur for teasers; SVG fallback if ImageMagick is missing.
- `ForensicWatermarkService`: per-buyer stamp + EXIF. **If ImageMagick is not installed the original file is served unwatermarked** (see TODO).
- Viewer overlay repeats `@handle · ID n`; context menu disabled; downloads only when the creator allows them, and still watermarked.

---

## 3. Technology Stack

| Layer | Technology | Details |
|---|---|---|
| Language | Ruby 3.4.4 | RVM in WSL (`~/.rvm/rubies/ruby-3.4.4`) |
| Framework | Rails 8.0.2 | `rails/pwa` controller for manifest and service worker |
| Database | PostgreSQL | Solid Cable / Queue / Cache |
| Frontend | Turbo Drive + vanilla JS | `public/assets/js/{turbo.min,wf,chat,share,actioncable}.js`, no bundler |
| Styling | `public/assets/wf.css` | Dark system, `w-` prefixed classes; `wishful.css` still loads underneath for legacy forms |
| Helpers | `app/helpers/wf_helper.rb` | Icons (from the design files), avatars, cover sources, Studio nav, chart paths, QR SVG |
| Real-time | ActionCable | `ConversationChannel`, `LiveChatChannel` |
| Storage | ActiveStorage | local disk in development |
| Image processing | ImageMagick | Frosted previews, watermarks |
| QR | rqrcode | UPI QR and link-list QR |
| Push | web-push | VAPID Web Push |
| CSV | csv | Payments export (no longer a default gem in Ruby 3.4) |
| Messaging | WhatsApp Cloud API | `WhatsappClient`, template sends, logs when unconfigured |

---

## 4. Design System (dark, Oct 2026)

| Token | Value | Use |
|---|---|---|
| `--w-bg` | `#0E0E10` | Page |
| `--w-bg-deep` | `#0A0A0C` | Studio sidebar, side panels |
| `--w-card` | `#16161A` | Cards, inputs |
| `--w-raise` / `--w-btn` | `#1C1C20` / `#232327` | Raised chips, secondary buttons |
| `--w-line` / `--w-line-2` | `#26262A` / `#3A3A40` | Borders |
| `--w-text` / `--w-soft` / `--w-sub` / `--w-dim` | `#F5F5F7` / `#D4D4D8` / `#A1A1AA` / `#71717A` | Text |
| `--w-pink` | `#E0306A` | The paid action, active states, verified tick |
| `--w-gold` | `#F5B942` | Close Friends, "Yours", cover tag |
| `--w-green` | `#4ADE80` | Money received, approved, live status |
| `--w-rose` | `#F87196` | Errors, short payments |

- Type: Plus Jakarta Sans 400–800; titles 28px/800/-0.03em; labels 11–12px/800 uppercase tracked.
- Radii: 8–12px controls, 14–16px cards, 999px pills; buttons 40px (Studio) / 54px (fan CTAs).
- Layout chromes (`content_for :chrome`): `fan` (phone-width, ≤480px), `list` (link-list page, blurred backdrop on desktop), `studio` (220px sidebar), `marketing`, `bare`. Signed-in creators default to `studio`, fans to `fan`.
- The five creator themes (`User::THEMES`) are kept in the database but no longer change the storefront.
- **Light theme**: every viewer picks Dark (default) / Light / System. The choice is a `wf_theme` cookie set by `PATCH /theme` (`ThemesController`) and rendered as `<html data-theme>`. System is resolved by an inline script before paint. Light tokens: page `#F6F5F2`, cards `#FFFFFF`, text `#17151A`, pink `#D6245F`, gold text `#A86A00` (gold fills stay `#F5B942`), green `#15803D`. The viewer, live room and lives card stay dark in both themes. The switch (`shared/_theme_switch`) sits in the Studio sidebar, Settings › Account and the fan top bars (storefront, unlocks).

---

## 5. Domain Model

```
User (creators & fans; email optional when phone_number is set)
 ├── paid_media_collections ── paid_media_posts (ordered by position; first = cover)
 │                          └── access_purchases (as purchasable)
 ├── paid_media_posts (standalone drops have no collection) ── media_purchases
 ├── subscription_plans ── creator_subscriptions
 ├── link_lists ── items (LinkListItem: url | product_link | collection)
 ├── link_collections ── product_links ── link_clicks
 ├── creator_posts (optional paid_media_collection) ── likes, comments
 ├── contact_reveals ── access_purchases
 ├── meet_offers ── meet_slots ── meet_booking
 ├── wishlists ── wishlist_items ── gift_contributions
 ├── live_sessions ── live_messages
 ├── creator_conversations / fan_conversations ── direct_messages ([ppv:ID] / [collection:ID] cards)
 ├── payment_claims (as claimant) / received_payment_claims (as creator), optional link_list
 ├── push_subscriptions
 ├── events (partitioned monthly by created_at) — actor_id, creator_id, action, target, properties
 ├── creator_daily_stats — rollups by creator_id & date
 ├── content_daily_stats — rollups by content_type, content_id, date
 ├── referral_daily_stats — rollups by creator_id, date, source
 ├── fan_profiles — composite scoring, spend, tier (whale, super_fan, regular, casual, lurker)
 ├── notifications — in-app notification inbox
 ├── user_sessions — JWT & PWA session tracking
 ├── feed_items — fan-out-on-write reverse chronological fan timeline
 └── attachments: profile_picture, banner, upi_qr
OtpCode (phone_number, code_digest, expires_at, attempts, consumed_at)
```

**New Tables & Columns (October 2026 Analytics & PWA Update):**
- Counter cache columns:
  - `users`: `collections_count`, `posts_count`, `total_earned_cents`, `monthly_earned_cents`, `close_friends_count`, `unread_claims_count`, `last_active_at`
  - `paid_media_collections`: `views_count`, `unlocks_count`, `revenue_cents`, `pay_sheet_opens_count`, `utr_submissions_count`
  - `paid_media_posts`: `views_count`, `downloads_count`, `position`
  - `creator_posts`: `likes_count`, `comments_count`, `views_count`, `shares_count`
  - `link_lists`: `taps_count`, `earned_cents`
  - `live_sessions`: `peak_viewers`, `unique_viewers`, `gifts_cents`
- 8 New Tables: `events` (partitioned monthly), `creator_daily_stats`, `content_daily_stats`, `referral_daily_stats`, `fan_profiles`, `notifications`, `user_sessions`, `feed_items`.
- Services & Background Jobs:
  - `EventTracker`: Non-blocking async event dispatch by default, sync fallback for fulfillment.
  - `JwtService`: PWA session authentication & JWT token encode/decode with device fingerprinting.
  - `TrackEventJob` (`:analytics`): Async ingestion of analytics events into partitioned tables.
  - `CounterBufferJob` (`:counters`): Debounced recount & update of social metrics (`likes_count`, `comments_count`) preventing row-lock storms.
  - `NotifyJob` (`:messaging`): Off-request in-app notification creation and Web Push dispatch.
  - `UpdateConversationJob` (`:messaging`): Chat metadata bump, unread counters, and recipient notifications.
  - `DailyAnalyticsRollupJob` (`:analytics`): Nightly aggregation of creator, content, and referral stats.
  - `FanProfileRecalculateJob` & `IncrementFanProfileJob` (`:analytics`): Fan engagement scoring and tiering.
  - `FeedFanoutJob` (`:analytics`): Fan-out-on-write reverse chronological timeline distribution.
  - `ContentStatsAccumulatorJob` (`:analytics`): 15-minute intraday rollups for fresh Studio metrics.
  - `CreateMonthlyPartitionJob` (`:maintenance`): Auto-provisions upcoming month's event partition.

### 2.9 Nocturnal VIP Feed & Vector SVG Iconography Standard (`/feed`, `fan-app/src/app/feed/page.tsx`)
- **Header**: `WISHFUL ✦` tracked uppercase branding, search vector SVG, notification bell with unread ruby dot, and profile avatar badge with glowing ruby border.
- **Creator Rings Tray**: Horizontal highlights row featuring glowing neon ruby pulse ring (`ANJALI ✦`), VIP badges, and touchable story triggers.
- **Card Archetypes**:
  1. *Photo Post (Anjali Hegde)*: 4K Ultra HD badge, bottom glass sneak peek pill, quick reaction pills (`🔥 1.8k`, `🫦 1.1k`, `🍑 850`, `💘 620`), vector SVG action bar.
  2. *Interactive Poll (Kiara Roy)*: Real-time animated percentage bars (`68%` vs `32%`), final hours badge, vector SVG action bar.
  3. *The Vault Drop Album (Tara Kapoor)*: Cover preview with slide peek (`18 Ph...`), `PUBLIC PREVIEW` tag, glowing ruby `🛍️ UNLOCK VAULT DROP • ₹499 (DIRECT UPI)` button with instant UTR claim sheet.
  4. *Audio Whisper Drop (Rhea Sen)*: ASMR whisper tag, animated equalizer waveform, skip 15s vector controls, spatial binaural 3D & FLAC lossless tags.
  5. *Video Reel Teaser (Zara Velvet)*: 60fps Dolby Vision tag, audio mute toggle SVG, center play button, duration scrubber line, quick spicy reactions bar.
  6. *Locked Stream Replay (Kiara Roy)*: Replay archive stats, center lock insignia, direct unlock button at ₹299.
- **High-Quality Vector SVG Icon Standard**:
  - Replaces all legacy emoji text characters in interactive actions with crisp, resolution-independent vector SVGs.
  - Heart: sleek outline or solid ruby-filled with neon bloom glow.
  - Comment: rounded modern vector message bubble.
  - Bookmark: elegant ribbon banner (outline or solid gold-filled).
  - Share: crisp curved vector icon.
  - More: horizontal three dots SVG.
- **Dedicated Full-Page Post Viewer (`/feed?post=[id]`)**:
  - Replaces modal popup overlays with a dedicated page navigation model featuring a sticky header with `<` Back button, creator avatar with pink star ring, verified checkmark badge, and `+ Follow` action.
  - Automatically hides the bottom navigation bar (`body.hide-bottom-nav`) while viewing a single post to focus attention on the content and discussion.
  - Discussion thread with pinned creator comments, VIP fan comments with timestamps, likes, and reply counts.
  - Fixed bottom comment composer bar strictly constrained to the 480px mobile PWA container (`max-width: 480px; left: 50%; transform: translateX(-50%); box-sizing: border-box;`), featuring 6 quick reaction emojis (`🔥`, `😈`, `🌶️`, `🫦`, `🪽`, `🎧`), avatar, rounded input field with smiley trigger, and electric ruby gradient send button.
- **4-Tab Nocturnal Bottom Navigation**: `FEED`, `VAULT`, `POST +`, `VIP` with tracked uppercase Plus Jakarta Sans typography.

### 2.10 Stitch Studio Architecture Standard (Obsidian Velvet, Neon Ruby)
The five core Studio creator screens have been implemented with pixel-to-pixel precision matching Google Stitch project `3128119346421041736` (`Creator MarketPlace`), refined to full production SaaS quality (Linear / Vercel standard):
0. **Overview & Console (`/dashboard`, `DashboardController#show`)**:
   - Header with `Studio > Console` breadcrumb, Atelier Intelligence settlement tag (`• ATELIER INTELLIGENCE • LIVE SETTLEMENT NODE / Direct P2P Architecture`), personalized greeting with star sparkles (`Welcome back, Aura ✨`), and top action bar with statement CSV export and electric ruby `+ Quick Action` pill.
   - 4-metric KPI summary bento grid: Monthly Net Revenue (₹4,16,316, +21.4% trend, 100% Direct UPI P2P, 0% Platform Fee), Total Active Patrons (184 Members, +14 billing cycle growth, 96.4% VIP Retention), Vault Drop Unlocks (342 Unlocks, ₹3,24,500 gross yield, 8 active circulation drops), and Feed & Media Reach (482.5K Views, 16.8% avg engagement, Studio Tier TOP 0.1%).
   - Pending Verifications banner: Glowing plum-ruby card displaying pending UPI claims (3 claims, ₹1,797 total) with instant `Review & Match UTRs ➔` deep-link.
   - Live Patron Transaction Ledger: Real-time connected table (`● LIVE STREAM CONNECTED`) tracking patron handles, access passes, instant amounts, settlement rail pills (Direct UPI HDFC, Auto-Matched UTR, Direct UPI ICICI), relative timestamps, and receipt inspection triggers.
   - Top Performing Vault Drops: Showcase grid featuring top PPV bundles with locked 4K / FPS badges, gross yields, sales counts, and `Edit Drop` triggers.
   - Fast Lane Creator Actions: 2x2 grid for immediate creation (`+ Create Feed Post`, `+ New Vault Drop`, `Schedule Live`, `Curate Sourcing`).
   - Upcoming Scheduled Drop: Nightly countdown card featuring "Velvet Mirage (Teaser Live)" with `TONIGHT` badge, 11:59 PM IST reminder, and audio/room gate setup action.
   - Direct UPI Settlement Node: Live status card (`● ACTIVE`) displaying verified VPA (`aura@okhdfcbank`), NPCI 2.4s SLA guarantee, escrow mode breakdown, daily volume, and Gateway & VPA Settings action.
1. **Posts & Content Analytics (`/creator_posts`, `CreatorPostsController#index`)**:
   - Fixed `w-[260px]` sidebar with live UPI status indicator, user badge, active state glow, and structural hairline border (`border-r border-white/[0.06]`).
   - Header bar with search input (⌘K) and notification indicators.
   - 4-metric KPI bar: Total Public Posts, Impressions, Avg. Engagement Rate, Media Retention with subtle hairline contrast borders.
   - Client-side interactive filter tabs (All Posts, Photo Sets, 4K Reels & Video, Audio Whispers, Polls) and real-time live search.
   - Content inventory table with thumbnail badges (12P, 4K, 04:12, LIVE, RAW), reach ratios, likes/comments counters, and feed/edit actions.
   - Minimalist pagination controls and CSV audit export.
2. **Create Post (`/creator_posts/new`, `CreatorPostsController#new/create`)**:
   - Two-column editorial composition grid (68% studio / 32% controls).
   - 5 post-type tabs: `Text & Story`, `Photo Set`, `4K Reel / Video`, `Audio Whisper`, `Interactive Poll`.
   - Clean placeholder states without hardcoded prototype narrative text.
   - Editorial title input + WYSIWYG formatting toolbar (Bold, Italic, Strikethrough, Link, Spoiler Blur) + narrative caption with live 2,200 character counter.
   - Dynamic drag-and-drop file upload zone reading live file metadata (filename, size in MB) and generating dynamic previews.
   - Collapsible Interactive Community Poll accordion (Question, Option 01 & 02, duration) expanding automatically on poll tab selection.
   - Wardrobe & sourcing product credits manager with dynamic tag creation.
   - Sticky sidebar: Access & Audience (Public vs VIP), Publish Cadence (Now vs Scheduled Drop), Precision Controls (Pin, VIP Whisper, Dynamic Forensic Watermark), and neon-bloom CTA button.
3. **Collections & Vault (`/paid_media_collections`, `PaidMediaCollectionsController#index`)**:
   - Vault Engine 4.2 header with instant live search and revenue sorting.
   - 3 KPI performance cards: Total Gross Vault Revenue, Active Vault Inventory (with circular SVG completion meter), and Top Converting Bundle with subtle top-right badge (replacing legacy rotated ribbon).
   - Segmented classification pills with instant client-side filtering: All Vault Items, Bundles & Collections, Single 4K Sets, Video Masterclasses.
   - 2-column inventory grid with locked overlays, items count, pricing, unlock metrics, and DRM badges.
   - Direct UPI P2P Settlement Guarantee banner (0% platform cut, < 2.4s SLA, creator VPA).
   - Modal drawer (`#createDropModal`) for publishing new PPV vault drops with price, classification, working file input, and DRM toggles.
4. **Subscribers & VIP Patrons (`/subscribers`, `SubscribersController#index`)**:
   - Patronage architecture header with CSV export and "+ Create VIP Tier" CTA.
   - 3-metric KPI summary bento cards: Total Active Patrons, Monthly Recurring Revenue (Direct UPI 0% Fee), and Member Retention (96.4%).
   - 3 Active VIP Tier cards: Tier 01 Close Friends Pass (₹499/mo), Tier 02 Inner Circle (₹999/mo), Tier 03 Sultan Patron (₹2,499/mo).
   - Patrons roster master table with live interactive filter tabs (All, Active, Expiring Soon), real-time search by handle or UTR, calm renewal status indicators (replacing frantic animations), live count badges, and direct messaging actions.
5. **Live Broadcast Scheduling & On-Air Studio (`/lives/new`, `/lives/:id/studio`, `LiveSessionsController`)**:
   - **Schedule Suite (`/lives/new`)**:
     - Breadcrumb `STUDIO > LIVE BROADCAST > SCHEDULE` with `DIRECT RTMP/UPI` badge.
     - Step 01: Broadcast session details with title, 80-char counter, Markdown VIP teaser description, scheduled datetime with `PEAK FAN SLOT` tag, and duration selector pills (30m, 45m, 60m, Open).
     - Step 02: 3-tier admission gatekeeper cards: Public Teaser + VIP Transition (5m viral teaser), VIP Patrons Only (Close Friends/Inner Circle inclusion), and Ticketed PPV Live (one-click ₹299 pass).
     - Step 03: Direct stream ingest with Browser Cam vs OBS / RTMP Pro switcher, copyable RTMP endpoint (`rtmps://live.wishful.app/live`), masked stream key with visibility reveal, and automated paywalled replay vaulting toggle.
     - Live Incentive Goal: Real-time fan crowd-funding meter toggle, goal target amount (`₹10,000` with ₹2.5k / ₹5k / ₹10k / ₹25k presets), milestone reward title, 3-tier unlock triggers (VIP Audio, Silhouette Costume Swap, Main Drape Reveal), and 64% simulated HUD momentum bar.
     - Interactive Controls & Moderation: Pay-to-Chat Tip Gate (`Min ₹50`), Chat Pace Regulation (`10s Delay`), Discreet Fan Watermark toggle, and VIP Alert Dispatch.
     - Past Broadcasts Archive Drawer: Modal drawer listing completed past sessions with studio inspect links.
   - **Live Broadcast Studio On-Air (`/lives/:id/studio`)**:
     - Telemetry Header: Glowing `● ON AIR / 00:44:14` timer badge, broadcast title with verified tick, `1,842 VIPs` viewer chip, `₹18,450.00` Instant UPI (0% fee) chip, `1080p60 • 6,200 kbps • 0 drops` stream health indicator, and `End Broadcast` call termination action.
     - UltraHD Video Stage: Nocturnal luxury stream simulation with animated `WHISPER EQ ACTIVE` audio spectrum, `WISHFUL FORENSIC WATERMARK ACTIVE` shield badge, camera lens indicator (`Lens: Sony FE 50mm f/1.2 GM`), and floating glass control dock (Mic, Video, `Studio ASMR` radiant pill, PIP, and Audio Settings).
     - Milestone Goal Meter: Radiant ruby progress bar (`74% Reached`), remaining milestone yield calculation, and recent tipper badges (`+₹500 @kabir_x`, `+₹200 @rohit_v`).
     - VIP Chat Stream: Pay-to-Chat (`₹50+`) tab switcher (`All Messages (89)` vs `Tips Only (24)`), styled patron chat cards with VIP badges & instant tip highlights, and pinned Host Priority announcement composer.

### 2.11 High-Concurrency Architecture, Job Queues & Real-Time Chat Scaling
Wishful is architected for viral creator traffic (concurrent likes, comments, and real-time broadcasts) without database row locks:
1. **Asynchronous Event Ingestion (`TrackEventJob`)**:
   - `EventTracker.track(action:, actor:, creator:, target:, properties:, request:)` extracts request metadata and enqueues `TrackEventJob` in the `:analytics` queue.
   - Database writes go to monthly partitioned `events` tables (`events_YYYY_MM`).
   - `EventTracker.track_sync` is retained for entitlement fulfillment and backfill.
2. **Debounced Counter Caching (`CounterBufferJob`)**:
   - Standard Rails `counter_cache: true` locks parent rows on every tap. Wishful replaces this with `CounterBufferJob` in the `:counters` queue.
   - Runs `COUNT(*)` asynchronously via `after_create_commit` and `after_destroy_commit` on likes and comments, updating `likes_count` and `comments_count` via `update_column`.
3. **Off-Thread Notifications (`NotifyJob`)**:
   - Creates in-app `Notification` rows and triggers Web Push via `:messaging` queue.
   - Built-in deduplication prevents notifying a user of their own actions.
4. **Chat & Real-Time Messaging (`UpdateConversationJob`, `ConversationChannel`)**:
   - ActionCable broadcasts messages, typing indicators (`typing`), and read receipts (`read`) over WebSockets without DB blocking.
   - `UpdateConversationJob` runs in `:messaging` queue to update `last_message_at`, unread counters, analytics, and push notifications.
   - `config/cable.yml` supports Redis Pub/Sub in production via `REDIS_URL` with Solid Cable fallback.
5. **Intraday & Nightly Rollups (`config/recurring.yml`)**:
   - `DailyAnalyticsRollupJob`: Nightly at 2:00 AM IST (20:30 UTC).
   - `FanProfileRecalculateJob`: Nightly at 3:00 AM IST (21:30 UTC).
   - `ContentStatsAccumulatorJob`: Every 15 minutes for intraday Studio stats freshness.
   - `CreateMonthlyPartitionJob`: 25th of each month for next month's partition creation.

---

## 6. Routes

| Path | Controller#Action | Purpose |
|---|---|---|
| `GET /` | `pages#home` | Marketing home |
| `GET /start` · `/start/profile` · `/start/upi` · `/start/live` | `onboarding#*` | Creator sign-up, 4 steps |
| `GET/POST /sign_in` · `GET /sign_in/email` | `sessions#*` | Phone sign-in; email fallback |
| `POST /otp` · `GET/POST /otp/verify` · `POST /otp/resend` · `GET /join` | `otp#*` | OTP send/verify; fan sign-in at pay time |
| `GET /feed` | `feed#index` | Fan Feed: Timeline of drops, posts, lives |
| `POST /feed_items/:id/seen` | `feed_items#seen` | Mark feed item seen |
| `GET /discover` | `discover#index` | Explore: Trending vault drops & categories |
| `GET /:handle` | `profiles#show` | Storefront (`?tab=`) |
| `GET /:handle/c/:id` · `/:handle/c/:id/view` | `paid_media_collections#show/viewer` | Collection page; watermarked viewer |
| `GET /:handle/d/:id` | `paid_media_posts#show` | Standalone drop (`?view=1` viewer) |
| `GET /:handle/p/:id` | `creator_posts#show` | Public post |
| `GET /:handle/close-friends` · `/:handle/spoil-me` | `profiles#close_friends/spoil_me` | Join Close Friends; group gift |
| `GET /:handle/:slug` | `link_lists#public` | Public link list |
| `GET /l/:id` | `link_list_items#visit` | Counted tap redirect |
| `GET/POST /pay/:type/:id` | `payment_claims#new/create` | Pay sheet + UTR claim |
| `GET /payment_claims/:id` | `payment_claims#show` | Fan receipt: waiting / approved / rejected |
| `GET /payment_claims(.csv)` · `POST …/approve|reject|nudge` | `payment_claims#*` | Studio · Payments |
| `GET /unlocks` | `unlocks#index` | Fan library, PWA start page |
| `GET /dashboard` | `dashboard#show` | Studio · Overview |
| `/creator_posts` (+ `/new`, `/edit`, `.csv`) | `creator_posts#index/new/create/edit/update/destroy` | Studio · Posts & Content Analytics + Create Post (Stitch Screen 1 & 2) |
| `/paid_media_collections` (+ `POST :id/items`, `PATCH :id/reorder`, `DELETE :id/items/:post_id`) | `paid_media_collections#*` | Studio · Collections & Vault (Stitch Screen 3) |
| `GET /subscribers` | `subscribers#index` | Studio · Subscribers & VIP Patrons (Stitch Screen 4) |
| `/product_links` · `/collections` | `product_links#*`, `collections#*` | Studio · Shop and its categories |
| `/lists` (+ `PATCH :id/reorder`, `GET :id/qr`, `/lists/:id/items`) | `link_lists#*`, `link_list_items#*` | Studio · Link lists |
| `GET /schedule` | `schedule#show` | Studio · Book (`?week=YYYY-MM-DD`) |
| `/conversations` | `conversations#*` | Studio inbox / fan chat |
| `GET/PATCH /creator_settings` | `creator_settings#*` | Studio · Settings |
| `/lives/:id` · `/lives/:id/studio` | `live_sessions#*` | Live room; creator phone studio |
| `POST /api/v1/auth/otp` · `/verify` · `GET /me` | `api/v1/sessions#*` | PWA JWT auth |
| `GET /api/v1/feed` | `api/v1/feed#index` | PWA Fan feed data API with rich archetype serialization & curated discovery fallback |
| `GET /api/v1/posts/:id` | `api/v1/posts#show` | Detailed post metadata with creator info, media, tags, likes & bookmarks |
| `POST/DELETE /api/v1/posts/:id/like` | `api/v1/posts#like/unlike` | Fan post likes toggle with real-time counter updates & event sourcing |
| `POST/DELETE /api/v1/posts/:id/save` | `api/v1/posts#bookmark/unbookmark` | Fan post bookmarks / save to vault library |
| `GET/POST /api/v1/posts/:id/comments` | `api/v1/post_comments#index/create` | Fan post discussion comments thread with VIP & creator badges |
| `GET /api/v1/discover` | `discover#index` (json) | PWA Explore data API (content & creator subtabs) |
| `GET /api/v1/creators/:handle` (+ `/follow`) | `api/v1/creators#*` | In-app creator profile & follow API with feed sync |
| `POST /api/v1/payment_claims` | `api/v1/payment_claims#create` | In-app 12-digit UTR UPI unlock API |
| `GET /api/v1/notifications` (+ `POST :id/read`) | `api/v1/notifications#*` | Fan in-app notifications |
| `POST /api/v1/events` | `api/v1/events#create` | Client-side analytics event ingestion |
| `GET /paid_media_posts/:id/media` · `/preview` | `paid_media_posts#media/preview` | Watermarked media; frosted teaser |
| `POST/DELETE /push_subscriptions` | `push_subscriptions#*` | Web Push registration |
| `GET /manifest.webmanifest` · `/service-worker.js` · `/offline` | `rails/pwa#*`, `pages#offline` | PWA |
| `PATCH /theme` | `themes#update` | Dark / light / system cookie |

---

## 7. Development & Testing Reference

- **Quick Start (Development Environment):**
  - **Rails Backend** (Ruby 3.4.4, Rails 8.0.2):
    ```bash
    ~/.rvm/wrappers/ruby-3.4.4/bundle exec rails s
    # Default port: http://localhost:3000
    ```
  - **Fan App PWA** (Next.js 16 / TypeScript):
    ```bash
    cd fan-app && npm run dev -- -p 3001
    # Default port: http://localhost:3001
    ```
- **Database & Migrations:**
  - `bin/rails db:migrate`
  - `bin/rails db:seed` (idempotent; seed accounts use password `password123`)
- **Background Jobs & Solid Queue:**
  - Rails 8 Solid Queue runs automatically in development via Puma plugin (`SolidQueue::Supervisor`).
  - To inspect or run dedicated background job workers: `bin/rails solid_queue:start`.
  - Recurring scheduled jobs are defined in `config/recurring.yml` (daily rollups, intraday stats accumulator, fan profile calculations, monthly partitions).
  - Job queues: `:analytics`, `:counters`, `:messaging`, `:maintenance`, `:default`.
- **ActionCable / Real-Time Messaging:**
  - In development: `async` adapter in `config/cable.yml`.
  - In production: Set `REDIS_URL` to enable Redis pub/sub adapter, or defaults to Solid Cable (`database: cable`).
- **Flagship Seed Personas:**
  - Creator: `ananya@example.com` / `@ananyarao` (4 collections, link lists, payment claims queue).
  - Fan: `priya@example.com`, phone `+91 98765 43210` (owns *Banarasi Heritage*).
- **Phone sign-in in development:** OTP is logged to `log/development.log` (`[whatsapp:log]`) and displayed in the flash alert.
- **ImageMagick:** `sudo apt install imagemagick` (or `brew install imagemagick` on macOS) for frosted previews and dynamic forensic watermarking.
- **Continuing On Another Machine / Workplace:**
  - Clone/pull repository.
  - Install dependencies: `bundle install` and `(cd fan-app && npm install)`.
  - Setup DB: `bin/rails db:create db:migrate db:seed`.
  - Check `REFERENCE.md`, `FEATURES.md`, and `TODO.md` which are kept continuously updated.
- **Key Environment Variables for Production:**
  `DATABASE_URL`, `REDIS_URL`, `SECRET_KEY_BASE`, `WHATSAPP_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`, `WHATSAPP_OTP_TEMPLATE`, `WHATSAPP_NOTICE_TEMPLATE`, `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`.
