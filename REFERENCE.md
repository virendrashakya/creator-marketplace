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
- What it is: A mobile-first storefront and installable PWA where Indian creators (saree drapers, fashion models, GRWM and reels creators) get paid directly by fans.
- Core Value Proposition: 100% creator earnings, 0% platform rake. Fans pay the creator's own UPI ID (GPay, PhonePe, Paytm, BHIM) and submit the 12-digit UTR; the creator approves it and the unlock is granted.
- Tech Stack: Ruby on Rails 8.0 (Ruby 3.4.4), PostgreSQL, Turbo Drive, vanilla JS (no bundler, everything served from public/), ActionCable (Solid Cable), Solid Queue/Cache, ActiveStorage, ImageMagick, rqrcode, web-push.
- Design: one dark system (`public/assets/wf.css`): near-black #0E0E10, ruby pink #E0306A for the paid action, gold #F5B942 for Close Friends and "yours", green #4ADE80 for money in. Plus Jakarta Sans. Fans get a phone-width app; creators get "Studio", a sidebar web app.
- Key Capabilities:
  1. Storefront /:handle with four tabs: Posts (free), Collections (covers only, locked), Shop (affiliate looks), Book (calls, lives, paid access).
  2. Collections: the unit fans buy. First item is the public cover; the rest stay hidden until unlocked by price or by Close Friends. Watermarked full-screen viewer.
  3. Close Friends: monthly pass (SubscriptionPlan) that unlocks the collections included in it, members-only lives and priority DMs.
  4. Pay sheet + UTR claims + creator approval queue (Payments), with reused-UTR and amount-mismatch flags, optional auto-approve, CSV export.
  5. Link lists: one shareable URL (/:handle/:slug) holding socials, products, videos and the creator's own collections, with opens/taps/earnings.
  6. Phone-first accounts: WhatsApp OTP sign-up for creators (4 steps); fans only sign in at the moment they pay.
  7. DMs with paid media cards, Close Friends lives with chat, Spoil Me group gifts, 1:1 call booking.
  8. PWA: manifest, service worker, offline unlocks, install prompt, Web Push for approvals.
  9. DRM: FrostedPreviewService (server-side blur) + ForensicWatermarkService (buyer handle/ID stamped into each unlocked image) + on-screen watermark overlay.
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
- **Posts** `/creator_posts`: grid + composer (media, caption, link a collection, draft or post now). Public post page `/:handle/p/:id` with likes, comments and the teased collection.
- **Shop** `/product_links`: affiliate links with taps, categories (`LinkCollection`).
- **Book** `/schedule`: week calendar (calls, lives, open slots) + "What fans can book" switches for meet offers and contact reveals.
- **Messages** `/conversations`: three panes (list with All / Close Friends / Unread, thread with "Paid media" picker for `[ppv:ID]` / `[collection:ID]` cards, fan panel with spend, collections owned, Close Friends since, last gift, Block).
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
 └── attachments: profile_picture, banner, upi_qr
OtpCode (phone_number, code_digest, expires_at, attempts, consumed_at)
```

New columns (migration `20261013010000_studio_redesign`): `users.phone_verified_at, blog_url, backup_upi_id, auto_approve_under_cents, notify_whatsapp_claims, onboarded_at` (+ unique partial index on `phone_number`, `email` now nullable); `paid_media_collections.release_at, allow_downloads`; `paid_media_posts.position`; `creator_posts.paid_media_collection_id`; `payment_claims.link_list_id`; tables `link_lists`, `link_list_items`, `otp_codes`, `push_subscriptions`.

---

## 6. Routes

| Path | Controller#Action | Purpose |
|---|---|---|
| `GET /` | `pages#home` | Marketing home |
| `GET /start` · `/start/profile` · `/start/upi` · `/start/live` | `onboarding#*` | Creator sign-up, 4 steps |
| `GET/POST /sign_in` · `GET /sign_in/email` | `sessions#*` | Phone sign-in; email fallback |
| `POST /otp` · `GET/POST /otp/verify` · `POST /otp/resend` · `GET /join` | `otp#*` | OTP send/verify; fan sign-in at pay time |
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
| `/creator_posts` | `creator_posts#index/create/edit/update/destroy` | Studio · Posts |
| `/paid_media_collections` (+ `POST :id/items`, `PATCH :id/reorder`, `DELETE :id/items/:post_id`) | `paid_media_collections#*` | Studio · Collections + editor |
| `/product_links` · `/collections` | `product_links#*`, `collections#*` | Studio · Shop and its categories |
| `/lists` (+ `PATCH :id/reorder`, `GET :id/qr`, `/lists/:id/items`) | `link_lists#*`, `link_list_items#*` | Studio · Link lists |
| `GET /schedule` | `schedule#show` | Studio · Book (`?week=YYYY-MM-DD`) |
| `/conversations` | `conversations#*` | Studio inbox / fan chat |
| `GET/PATCH /creator_settings` | `creator_settings#*` | Studio · Settings |
| `/lives/:id` · `/lives/:id/studio` | `live_sessions#*` | Live room; creator phone studio |
| `GET /paid_media_posts/:id/media` · `/preview` | `paid_media_posts#media/preview` | Watermarked media; frosted teaser |
| `POST/DELETE /push_subscriptions` | `push_subscriptions#*` | Web Push registration |
| `GET /manifest.webmanifest` · `/service-worker.js` · `/offline` | `rails/pwa#*`, `pages#offline` | PWA |
| `PATCH /theme` | `themes#update` | Dark / light / system cookie |

---

## 7. Development & Testing Reference

- **Run in WSL (Ubuntu-22.04):** `cd /mnt/c/Users/703344457/Documents/development/creator-marketplace && bin/rails server -b 0.0.0.0` → http://localhost:3000.
- **Seed:** `bin/rails db:seed` (idempotent). Password for every seeded email account: `password123`.
- **Flagship creator:** `ananya@example.com` / `@ananyarao`: 4 collections (one scheduled), 3 link lists (`/ananyarao/diwali`, `/grwm`, hidden `/kit`), payment queue with mismatches.
- **Fan:** `priya@example.com`, phone `+91 98765 43210`; owns *Banarasi Heritage* (bought via the Diwali list).
- **Phone sign-in in development:** no WhatsApp provider is configured, so the OTP is shown in the flash on the verify screen and written to `log/development.log` (`[whatsapp:log]`).
- **ImageMagick:** install in WSL (`sudo apt install imagemagick`) for frosted previews and watermarks; without it teasers fall back to an SVG and unlocked media is served without a watermark.
- **Environment variables for production:** `WHATSAPP_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`, `WHATSAPP_OTP_TEMPLATE`, `WHATSAPP_NOTICE_TEMPLATE`, `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`.
