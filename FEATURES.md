# Wishful — Product Features & Architecture Specification

Wishful is a direct-to-creator monetization and exclusive content platform designed specifically for the Indian creator economy. Creators keep **100% of every rupee** through direct peer-to-peer UPI settlements, while protecting exclusive digital assets with server-side DRM and anti-leak infrastructure.

---

## 📑 Feature Index

1. [The Vault: PPV Media & Exclusive Drops](#1-the-vault-ppv-media--exclusive-drops)
2. [Content Security & Anti-Leak DRM Shield](#2-content-security--anti-leak-drm-shield)
3. [Controlled Viral Social Sharing Engine](#3-controlled-viral-social-sharing-engine)
4. [Close Friends & VIP Subscriptions](#4-close-friends--vip-subscriptions)
5. [Direct Contact & Private Channel Reveals](#5-direct-contact--private-channel-reveals)
6. [Private 1:1 Direct Messaging & Chat PPV](#6-private-11-direct-messaging--chat-ppv)
7. [1:1 Time Bookings & Live Broadcasts](#7-11-time-bookings--live-broadcasts)
8. [Wishlist & Gifting ("Spoil Me")](#8-wishlist--gifting-spoil-me)
9. [Curated Recommendations & Affiliate Collections](#9-curated-recommendations--affiliate-collections)
10. [Direct UPI Settlement & Manual UTR Verification](#10-direct-upi-settlement--manual-utr-verification)
11. [Dark "Studio" Design System](#11-dark-studio-design-system-oct-2026-redesign)
12. [Fan Storefront](#12-fan-storefront-handle)
13. [Collections & the Unlock Flow](#13-collections--the-unlock-flow)
14. [Creator Studio](#14-creator-studio)
15. [Link Lists](#15-link-lists)
16. [Phone-First Accounts & Onboarding](#16-phone-first-accounts--onboarding)
17. [Installable PWA](#17-installable-pwa)
18. [Design Documentation & Visual Reference](#18-design-documentation--visual-reference)
19. [Live Broadcast Studio & Scheduler](#19-live-broadcast-studio--scheduler)
20. [Scalable Analytics Database Architecture](#20-scalable-analytics-database-architecture)
21. [Next.js + Workbox PWA App](#21-nextjs--workbox-pwa-app-fan-app)
22. [Nocturnal VIP Feed Screen & Vector SVG Iconography Standard](#22-nocturnal-vip-feed-screen--vector-svg-iconography-standard)
23. [Scalable Job Pipeline & High-Concurrency Social Architecture](#23-scalable-job-pipeline--high-concurrency-social-architecture)

---

## 1. The Vault: PPV Media & Exclusive Drops

The Vault is the creator's private gallery for premium, behind-the-scenes, and exclusive content.

- **Pay-Per-View (PPV) Photo & Video Sets**: Single images or multi-photo photo shoots priced in INR (`₹99`, `₹199`, `₹499`, `₹999`).
- **4K Video Teasers & Streaming**: Support for high-resolution video drops delivered via dedicated, gated media endpoints.
- **Collections & Bundles**: Creators can bundle related shoots into episodic collections (e.g. *"The Goa Uncut Series"*).
- **Dynamic Lock Card UI**: Features high-contrast glowing pills (`VIP Vault Drop`), price badges, and frosted backdrop filters.
- **Post-Unlock States**: Instantly updates into an `"✨ Unlocked & Yours"` badge with immediate full-resolution viewing.

---

## 2. Content Security & Anti-Leak DRM Shield

Engineered to prevent the rampant scraping and anonymous redistribution plaguing platforms like Patreon and early OnlyFans.

### A. Backend-Only Frosted Teaser Previews (`FrostedPreviewService`)
- **Irreversible Image Blur**: Teasers are processed entirely on the server using ImageMagick (`-resize 80x80^` downsampling to destroy facial frequency details, followed by `-gaussian-blur 0x16`).
- **Zero Raw File Exposure**: Visitors, web scrapers, and DevTools inspectors receive only genuinely blurred JPEG bytes. Unblurred files never travel over the wire until paid and verified.
- **High-Performance Caching**: Blurred JPEGs are disk-cached in `tmp/cache/frosted_previews/#{blob.key}.jpg` with HTTP `ETag` and `Cache-Control: public, max-age=86400` headers (sub-15ms response times).

### B. Dynamic Forensic Watermarking (`ForensicWatermarkService`)
- **Buyer Attribution**: When an authenticated fan unlocks an image, the server dynamically burns their unique identity into the image pixels:
  - **Angled Center Watermark**: `@fan_handle • #fan_id` faintly etched across the subject (`rgba(255,255,255,0.18)`), resisting edge crops.
  - **Footer Attribution Banner**: High-contrast banner: `Licensed to @fan_handle (Fan #fan_id) • Wishful • YYYY-MM-DD`.
  - **EXIF Metadata Injection**: Licensee comment header embedded directly into the binary JPEG structure.
- **Creator Exemption**: The creator downloading their own media receives the 100% clean, un-watermarked original file.
- **Psychological & Legal Deterrence**: Leakers lose all plausible deniability; files uploaded to Telegram or Reddit directly identify the offending user ID.

### C. Client-Side Anti-Theft Shielding
- **Transparent Security Shield (`.media-shield`)**: An invisible overlay element sitting directly above the media intercepting mouse and pointer events.
- **Interaction Lockdown**: `draggable="false"`, `oncontextmenu="return false;"`, and `pointer-events: none` block native browser "Save image as..." and drag-to-desktop gestures.
- **License Pill**: Displays a discreet `🔒 Licensed to @username` pill on unlocked cards to remind subscribers that redistribution is tracked.

### D. Identity Theft & Impersonation Prevention
- **Reserved Handle Blacklist**: `RESERVED_HANDLES` validation in `User` model prevents malicious users from registering or renaming accounts to `admin`, `support`, `official`, `wishful`, `security`, `billing`, etc.
- **Session Fixation Hardening**: `SessionsController#create` calls `reset_session` before authentication, preventing session hijacking on shared networks.

---

## 3. Controlled Viral Social Sharing Engine

Rather than fighting casual sharing, Wishful turns WhatsApp, Telegram, and Instagram group chats into viral sales channels.

- **Dynamic OpenGraph Unfurling**:
  - When a user shares a link into WhatsApp, Telegram, iMessage, Twitter, or Discord, rich cards automatically unfurl.
  - Generates drop-specific titles: `"[Title] — VIP Drop by [Creator] | Wishful"`.
  - Displays the **backend-frosted teaser thumbnail** directly in the chat preview with price and unlock instructions.
- **Tracked Referral Tokens**:
  - Links automatically include the sharing user's handle: `/@creator?tab=vault&drop=18&ref=username`.
  - Enables affiliate promoter tracking and credit attribution for fans who drive new paying customers.
- **One-Click Share Teaser Modal**:
  - Native Web Share API integration on mobile devices (opens native iOS/Android sheet to WhatsApp, Instagram DMs, etc.).
  - Desktop quick-actions for 1-click WhatsApp web, Telegram share, and clipboard copying.
- **Contextual Shared Teaser Banner**:
  - Visitors clicking a shared link land on the creator's page with the Vault tab pre-selected.
  - Displays a highlighted top banner: `"🎁 Shared by @fan • Viewing teaser for '[Title]'"` with a 1-click jump button directly to the card.

---

## 4. Close Friends & VIP Subscriptions

Recurring monthly memberships for top supporters.

- **Tiered VIP Passes**: Creators configure recurring monthly subscription tiers (e.g. `₹299/mo`, `₹499/mo`).
- **All-Access Unlock Engine**: Subscribed fans automatically gain access to all published vault drops without purchasing each item individually (`post.unlocked_for?(user)` checks `user.subscribed_to?(plan)`).
- **Close Friends Badge**: VIP members receive glowing subscriber badges and priority status in direct messages and live streams.

---

## 5. Direct Contact & Private Channel Reveals

Pay-to-reveal secret links and personal contact information.

- **Encrypted Contact Reveals**: Secret values (private WhatsApp VIP group links, Telegram channels, Discord invites, personal phone numbers) remain hidden on the server until paid.
- **One-Time UPI Unlock**: Fans pay a one-time fee to reveal the hidden link or contact handle.
- **Gated Delivery**: Unlocks are verified and stored in `AccessPurchase` records.

---

## 6. Private 1:1 Direct Messaging & Chat PPV

Real-time private communication channels with built-in paywalls.

- **ActionCable WebSocket Chat**: Low-latency, encrypted two-way direct messaging between creators and fans.
- **PPV Media Drops in Chat**:
  - Creators can insert locked media drops directly into private chat threads (`[ppv:18]`).
  - Cards render inline with frosted teaser previews, price labels, and 1-click UPI checkout.
  - Automatically flips to unlocked full media as soon as the creator approves payment.
- **Unread Counters & Typing Status**: Tracks creator and fan unread counts independently.

---

## 7. 1:1 Time Bookings & Live Broadcasts

Sell your time and reach through face-to-face appointments and member-only broadcasts.

- **Meet Slots**: Creators list 1:1 video call slots (e.g., 30-minute consultation or fan chat at `₹1,499`).
- **Slot Reservation & Booking**: Attendees book discrete calendar slots; double-booking is guarded by database constraints.
- **Live Studio & Streaming**:
  - Scheduled broadcasts with studio control room.
  - Members-only or public live sessions with real-time live chat messages (`LiveMessage`).

---

## 8. Wishlist & Gifting ("Spoil Me")

Fan-funded gifts and crowdfunding wishlist items.

- **Custom Wishlist Items**: Products the creator wants (cameras, outfits, accessories, gadgets) with target amounts.
- **Crowdfunded or Full Gifting**: Fans can contribute partial amounts (`GiftContribution`) or fund the entire item outright.
- **Gift Messages**: Fans attach personal notes of appreciation visible on the creator's dashboard.

---

## 9. Curated Recommendations & Affiliate Collections

The classic "Link in Bio" supercharged with deep curation.

- **Categorized Collections**: Organize links by topic (e.g. *Everyday Makeup*, *Camera Gear*, *Thrift Finds*).
- **Creator Context Over Descriptions**: Highlights the creator's personal reason for recommending the item rather than generic store marketing copy.
- **Click Analytics & Counter Cache**: Tracks clicks per link (`LinkClick`) with IP deduplication and referrer tracking.
- **Instant Search & Category Chips**: Fuzzy search kicks in automatically when a profile has 12+ links.

---

## 10. Direct UPI Settlement & Manual UTR Verification

The foundational payment model of Wishful — **zero fees, zero payment gateways, 100% creator earnings**.

- **No Middleman Gateway**: Eliminates Stripe/Razorpay 3–5% transaction fees and 18% GST withholdings. Payments flow directly from fan UPI app (GPay, PhonePe, Paytm) into the creator's personal bank account.
- **Unique Transaction Reference (UTR) Submission**:
  - The fan scans the creator's dynamic UPI QR code or enters their VPA (`handle@bank`).
  - The fan submits the 12-digit UTR reference code generated by their bank, with an optional screenshot proof.
  - Duplicate UTR submissions per creator are strictly rejected at the database level (`index_payment_claims_unique_utr_per_creator`).
- **Creator Review Queue (`PaymentClaimsController`)**:
  - The creator checks incoming claims against their banking app statement.
  - Tapping **"Approve"** immediately grants the entitlement in a database transaction (`PaymentFulfillment#grant!`).
  - Tapping **"Reject"** logs a rejection reason and notifies the fan.

---

## 11. Obsidian Velvet & Neon Ruby Design System (Oct 2026)

An uncompromising, late-night sensual chic aesthetic—merging high-end editorial luxury with the nocturnal pulse of exclusive VIP nightlife.

- **Stylesheet & Tokens**: `public/assets/wf.css` for Rails Studio/Storefront and `fan-app/src/app/globals.css` for Next.js PWA.
- **Palette**:
  - Base Canvas (Z0 Abyss): `#050406`, neutral core `#09080c` with warm violet undertone
  - Surface Layer 1 (Cards & Trays): Smoked obsidian `#0e0c12` with 24px backdrop blur and hairline ruby border `rgba(255, 23, 103, 0.12)`
  - Surface Layer 2 (Elevated Sheets & Popovers): `#181520` with 1px border tinted in `rgba(255, 23, 103, 0.12)`
  - Text: Alabaster primary `#fdf2f4`, soft `#e6bcc1`, silky twilight gray muted `#a39aa5`, dim `#716973`
  - Electric Ruby (Primary): `#ff1767`, active action gradient `linear-gradient(135deg, #ff1767 0%, #c026d3 100%)` with radiant neon bloom `box-shadow: 0 4px 20px rgba(255, 23, 103, 0.35)`
  - Secondary: Deep plum-rose velvet `#9d174d`
  - Tertiary: Rose quartz bloom `#fb7185`
  - Gold: `#F5B942` for Close Friends, VIP pass, and already owned assets (`#1E1A10` background with gold glow)
  - Green: `#4ADE80` for money received, approved, live broadcasts
  - Error / Rose: `#ffb4ab`
- **Typography**: **Plus Jakarta Sans** everywhere with extreme weight contrasts: razor-sharp tight headings against tracked uppercase VIP cues (`label-vip`, `letter-spacing: 0.14em`).
- **Shapes & Elevation**: Full pill silhouettes (`rounded-full`, `border-radius: 9999px`) on all buttons, badges, and interactive chips. Floating velvet trays with smoked glass blur and ruby neon ambient glow.

## 12. Fan Storefront (`/:handle`)

1. Top bar: handle, verified tick, share.
2. Avatar with pink→gold ring; posts · fans · collections.
3. Name, category · city, bio; Follow / Message / gift (or Edit profile / New post for the owner).
4. Highlights: VIP (Close Friends), Lives, on-profile link lists, Spoil me, Book.
5. Tabs: **Posts** (free, no prices), **Collections** (covers only, lock + item count, gold "Yours" once bought), **Shop** (category chips, affiliate cards), **Book** (call slots, lives, Paid DM / WhatsApp circle).
6. Floating Close Friends bar ("Get every collection" / "All N with Close Friends").
7. Desktop: magazine header with a 150px avatar, 4-column grids.
8. Empty states for a brand-new creator.

## 13. Collections & the Unlock Flow

- **Collection page** (`/:handle/c/:id`): the cover is public; everything else shows as locked tiles with a "+N"; one price, one button; "or get all N with Close Friends".
- **Pay sheet** (`/pay/...`): GPay / PhonePe / Paytm / BHIM deep links, UPI ID copy, QR, paste the UTR, optional screenshot, "Paid directly to {creator} · Wishful takes 0%".
- **Fan sign-in only when paying** (`/join`): phone + handle + WhatsApp OTP, then straight back to the pay sheet.
- **Waiting** (`/payment_claims/:id`): timeline, auto-refresh, push opt-in ("Know the moment it's yours"); approved → "Open it now"; rejected → "{creator} couldn't find this payment" with "Fix UTR and resend".
- **Reused UTR**: rejected inline with where-to-find-it help.
- **Viewer** (`/:handle/c/:id/view`): full-screen, server-side watermark plus an on-screen diagonal `@handle · ID` overlay, progress bars, thumbnails, keyboard paging, optional watermarked download when the creator allows it.
- **Close Friends** (`/:handle/close-friends`) and **Spoil Me** (`/:handle/spoil-me`, ₹101/₹501/₹1,001 or any amount).
- **Fan library** (`/unlocks`): pending claims, unlocked collections, Close Friends memberships; the PWA's start page.

## 14. Creator Studio (Obsidian Velvet Standard)

Sidebar web app (`w-[260px]`, `bg-surface-container-low/95 backdrop-blur-2xl`): Overview, Posts & Analytics, Create Post, Collections & Vault, Live Broadcast, Messages & DMs, Subscribers, Settings.

1. **Overview & Console (`/dashboard`, `DashboardController#show`)**:
   - Header with `Studio > Console` breadcrumb, Atelier Intelligence settlement tag (`• ATELIER INTELLIGENCE • LIVE SETTLEMENT NODE / Direct P2P Architecture`), personalized greeting with star sparkles (`Welcome back, Aura ✨`), and top action bar with statement CSV export and electric ruby `+ Quick Action` pill.
   - 4-metric KPI summary bento grid: Monthly Net Revenue (₹4,16,316 with +21.4% trend, 100% Direct UPI P2P, 0% Platform Fee), Total Active Patrons (184 Members, +14 billing cycle growth, 96.4% VIP Retention), Vault Drop Unlocks (342 Unlocks, ₹3,24,500 gross yield, 8 active circulation drops), and Feed & Media Reach (482.5K Views, 16.8% avg engagement, Studio Tier TOP 0.1%).
   - Pending Verifications banner: Glowing plum-ruby card displaying pending UPI claims (e.g. 3 claims, ₹1,797 total) with instant `Review & Match UTRs ➔` deep-link.
   - Live Patron Transaction Ledger: Real-time connected table (`● LIVE STREAM CONNECTED`) tracking patron handles, access passes, instant amounts, settlement rail pills (Direct UPI HDFC, Auto-Matched UTR, Direct UPI ICICI), relative timestamps, and receipt inspection triggers.
   - Top Performing Vault Drops: Showcase grid featuring top PPV bundles with locked 4K / FPS badges, gross yields, sales counts, and `Edit Drop` triggers.
   - Fast Lane Creator Actions: 2x2 grid for immediate creation (`+ Create Feed Post`, `+ New Vault Drop`, `Schedule Live`, `Curate Sourcing`).
   - Upcoming Scheduled Drop: Nightly countdown card featuring "Velvet Mirage (Teaser Live)" with `TONIGHT` badge, 11:59 PM IST reminder, and audio/room gate setup action.
   - Direct UPI Settlement Node: Live status card (`● ACTIVE`) displaying verified VPA (`aura@okhdfcbank`), NPCI 2.4s SLA guarantee, escrow mode breakdown, daily volume, and Gateway & VPA Settings action.
2. **Posts & Content Analytics (`/creator_posts`)**:
   - Header strip with Content Telemetry tag, title, and CSV Audit export.
   - 4 KPI metric cards: Total Public Posts (142+), Impressions (482.5K), Avg. Engagement Rate (16.8%), Media Retention (78%) with subtle structural hairline borders (`border-white/[0.06]`).
   - Client-side live filter tabs: All Posts, Photo Sets, 4K Reels & Video, Audio Whispers, Polls.
   - Real-time search across post titles and badges.
   - Content inventory table: thumbnail with badges (12P, 4K, 04:12, LIVE, RAW), reach ratios, likes/comments counters, and feed/edit/delete actions.
   - Apple-grade pagination.
3. **Create Post Studio (`/creator_posts/new`)**:
   - Two-column editorial composition grid (68% studio / 32% controls).
   - 5-Archetype Switcher: `Text & Story`, `Photo Set`, `4K Reel / Video`, `Audio Whisper`, `Interactive Poll`.
   - Clean placeholder inputs without pre-baked fake prototype copy for clean post creation.
   - Editorial title input + WYSIWYG formatting toolbar (Bold, Italic, Strikethrough, Link, Spoiler Blur) with 2,200 character counter.
   - Dynamic drag-and-drop file upload zone reading live file metadata (filename, size in MB) and generating dynamic previews.
   - Collapsible Interactive Community Poll accordion (Question, Option 01 & 02, voting duration) expanding automatically on poll tab selection.
   - Wardrobe & Sourcing credits manager with dynamic tag creation.
   - Sticky sidebar: Access & Audience (Public Feed vs VIP Tier Only), Publish Cadence (Immediate vs Midnight Drop), Creator Precision Controls (Pin, VIP Whisper Alert, Dynamic Forensic Watermark), and radiant neon-bloom CTA button.
4. **Collections & Vault (`/paid_media_collections`)**:
   - Vault Engine 4.2 header with direct P2P settlement indicators and real-time live search & sort.
   - 3 KPI performance cards: Total Gross Vault Revenue (₹3,24,500), Active Vault Inventory (8+ Drops, 342+ unlocks, 76.4% conv circular SVG meter), and Top Converting Bundle with elegant top-right badge (replacing legacy rotated ribbon).
   - Segmented classification pills with instant client-side filtering: All Vault Items, Bundles & Collections, Single 4K Sets, Video Masterclasses.
   - 2-column inventory grid with locked overlays, items count, pricing, unlock metrics, and dynamic buyer stamps.
   - Direct UPI P2P Settlement Guarantee banner (0% platform cut, < 2.4s SLA, creator VPA).
   - `#createDropModal` drawer for publishing new PPV vault drops with price, classification, working file input, and DRM toggles.
5. **Subscribers & VIP Patrons (`/subscribers`)**:
   - Patronage architecture header with CSV export and "+ Create VIP Tier" CTA.
   - 3-metric KPI summary bento cards: Total Active Patrons (184+), Monthly Recurring Revenue (₹91,816, Direct UPI 0% Fee), and Member Retention (96.4%).
   - 3 Active VIP Tier cards: Tier 01 Close Friends Pass (₹499/mo), Tier 02 Inner Circle (₹999/mo), Tier 03 Sultan Patron (₹2,499/mo).
   - Patrons roster master table with live interactive filter tabs (All, Active, Expiring Soon), real-time search by handle or UTR, calm renewal status indicators (replacing frantic animations), live count badges, and direct messaging actions.
6. **Payments**: Waiting / Approved / Rejected / All, stats (waiting, approved this month, rejected, average time to approve), CSV export, Approve / Reject / "Ask ₹N" for short payments (opens a DM), mismatch rows flagged.
7. **Book**: week calendar of calls, lives and open slots; switches for what fans can book.
8. **Messages & VIP Desk (`/conversations`, `/conversations/:id`, `ConversationsController`)**:
   - **Pane 1 (Inbox List)**: `Messages` header with `VIP DESK` badge, `+ Broadcast` action, filter tabs (`All (24)`, `VIP (18)`, `DMs (6)`, `Unread (3)` in ruby), real-time thread search, rich patron preview rows with VIP badges (`TOP 0.1%`, `₹500 TIP`, `PATRON • VIP PASS`, `BROADCAST • 184 PATRONS`), and P2P instant gateway status indicator (`● P2P Instant Gateway Online • 0% Platform Cut`).
   - **Pane 2 (Center Thread Workspace)**: Header with patron identity, online status, last tip amount, `TOP 0.1%` and Direct UPI badges, `Send Vault Teaser` & `Request Direct UPI Tip` action triggers; end-to-end encrypted watermark token banner (`kabir@oksbi`); rich message cards including Direct UPI tip attachment card (`₹500 Direct UPI Tip attached` with settled status), Studio Voice Note audio player with animated waveform EQ (`0:48s`), attached PPV Vault Drop card with patron claim status & uncompressed RAW tags; quick action toolbar (`Photo / Video`, `Attach Vault PPV`, `Audio Whisper`, `UPI Request`, `Quick Replies`), and conversation composer.
   - **Fan About Info & Patron Intel Drawer**: Toggled on-demand via the three-dot (`more_vert`) menu in the chat header (keeping the main chat spacious, focused, and completely uncluttered by default): slides in with VIP patron location (`Bandra West, Mumbai`), tier (`Tier 3 VIP / Inner Circle`), total Direct UPI volume card (`₹18,450`, 100% P2P settled), verified UPI ID (`kabir@oksbi`), quick creator actions (`Send Private Vault Drop`, `Create 1:1 Booking Slot`, `Custom Price Quote`), recent unlock activity, and block fan action.
10. **Live Broadcast Scheduling & On-Air Studio (`/lives/new`, `/lives/:id/studio`)**:
    - **Schedule Suite (`/lives/new`)**:
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

## 15. Link Lists

One URL (`/:handle/:slug`) holding a hand-picked list: socials chosen per list, products, videos, blog posts ("From my blog") and the creator's own collections (sold through Wishful, attributed to the list). Studio shows opens, taps, earnings and Live / Hidden / Off status; the editor has paste-a-link, + My collection, + From Shop, drag reorder, a live phone preview, and Copy / WhatsApp / Story / QR / Bio link sharing. Hidden lists still open by link.

## 16. Phone-First Accounts & Onboarding

- Creator sign-up in four steps: phone → WhatsApp OTP → handle, name, categories → UPI ID and payee name → live, with a first-collection prompt.
- Sign-in by phone OTP; email + password kept at `/sign_in/email` for older accounts.
- OTP codes: HMAC digest only, 10-minute expiry, 5 attempts, 30-second resend throttle.
- WhatsApp delivery through the WhatsApp Cloud API (`WhatsappClient`); without credentials the code is logged (and flashed in development).

## 17. Installable PWA

- Manifest, icons (192, 512, maskable, SVG), standalone display, `/unlocks` start page.
- Service worker: offline fallback page, cached shell, watermarked unlocks saved for offline viewing (cleared on sign-out), Web Push display and click-through.
- Install prompt (Android `beforeinstallprompt`, iOS Share-sheet hint).
- Web Push (`WebPushNotifier`, VAPID): creator gets new claims; fan gets approvals and rejections.

18. [Design Documentation & Visual Reference](#18-design-documentation--visual-reference)
19. [Fan Feed & Discovery Engine](#19-fan-feed--discovery-engine)
20. [Scalable Analytics Database Architecture](#20-scalable-analytics-database-architecture)
21. [Next.js + Workbox PWA App](#21-nextjs--workbox-pwa-app-fan-app)

---

## 18. Design Documentation & Visual Reference

- `docs/screenshots/redesign-2026-10/`: 18 screenshots of the redesign (fan screens at 390px, Studio at 1440px, desktop storefront and link list at 1280px).
- `DESIGN.md` and `docs/screenshots/01_…10_…` describe the previous light design and are kept for history.

---

## 19. Fan Feed & Discovery Engine

- **Home Timeline (`/feed`)**: A reverse-chronological, engagement-optimized feed for fans following creators. Exclusively streams content items (Vault collection drops, photo/video posts, polls, audio whisper drops, and live streams) with instant unlock CTA buttons.
- **Curated Discovery Fallback**: When a signed-in fan has 0 followed creators or when browsing as a guest, the feed automatically falls back to curated trending Vault drops and posts from top creators, ensuring new visitors never land on a blank timeline.
- **Interactive Social Actions API**:
  - `POST/DELETE /api/v1/posts/:id/like`: Toggle post likes with atomic counter caches and partitioned event tracking (`EventTracker.track("post_like")`).
  - `POST/DELETE /api/v1/posts/:id/save`: Save/bookmark drops and posts into the fan's personal vault library via `PostBookmark`.
  - `GET/POST /api/v1/posts/:id/comments`: Real-time post discussion thread with VIP pass detection (`subscribed_to_creator?`), creator verification, and time-ago timestamps.
- **Collection Drops as Purchase Funnels**: Unblurred, high-resolution collection covers appear in the feed with locked badges and instant "Unlock ₹299" pay CTAs hitting `POST /api/v1/payment_claims`.
- **Fan-Out on Write (`FeedFanoutJob`)**: When creators drop new collections, posts, or live sessions, background jobs batch-insert records into `feed_items` for every follower in milliseconds.
- **Instant Follow Sync & Unfollow Purge**: When a fan follows a creator via `Api::V1::CreatorsController#follow`, their 10 most recent posts and 5 live Vault drops are immediately seeded into `feed_items`. When unfollowing, `feed_items` for that creator are purged immediately.
- **Explore & Drops (`/discover`)**: Discovery surface showing dual pill subtabs (`Explore Content` and `Explore Creators`), horizontal category pills, and 1-tap follow buttons.

---

## 20. Scalable Analytics Database Architecture

- **Partitioned Event Sourcing (`events`)**: Monthly range-partitioned table tracking all user actions (profile views, collection opens, pay starts, unlocks, likes, comments, and shares). High-speed ingestion without locking or slow table scans.
- **Daily Rollup Tables**:
  - `creator_daily_stats`: Profiles views, unique fans, PWA vs Web visitors, collection/post engagement, revenue breakdown, and follower churn.
  - `content_daily_stats`: Per-album and per-post views, likes, shares, unlock conversions, and drop funnel analytics.
  - `referral_daily_stats`: Attribution tracking across Instagram bio, WhatsApp shares, direct links, and Link Lists.
- **Engagement Scoring & Fan Tiers (`fan_profiles`)**:
  - Composite formula weighting spend (₹1 = 3pts), unlocks (50pts), Close Friends loyalty (100pts/mo), likes (2pts), comments (5pts), messages (3pts), and shares (10pts).
  - Tiers: `whale` (5,000+ pts), `super_fan` (1,000-4,999 pts), `regular` (200-999 pts), `casual` (50-199 pts), and `lurker` (0-49 pts).
- **Zero-Scan Counter Caches**: Real-time counter columns on `users`, `paid_media_collections`, `paid_media_posts`, `creator_posts`, and `link_lists`.

---

## 21. Next.js + Workbox PWA App (`fan-app/`)

- **Monorepo Split**: Rails retains Studio (`wishful.in/dashboard`, `studio.wishful.in`) and public storefronts (`/:handle` for SEO, social unfurling, and link-in-bio). Next.js powers the high-speed installable fan PWA (`fan-app/`).
- **Workbox Service Worker (`sw.js`)**:
  - `NetworkFirst` offline caching for all unlocked photo/video sets with automatic background sync.
  - API caching with cache-fallback for timeline browsing while offline.
  - Standalone PWA web manifest with shortcuts for Feed, Explore, and Vault.
- **JWT & Session Auth (`JwtService`, `UserSession`)**: WhatsApp OTP verification issues 30-day JWT Bearer tokens with device/IP session revocation tracking.
- **Dynamic Header Auth Sync (`Header.tsx`)**: Reactive client component subscribing to `wf_auth_change` and `storage` events with automatic validation against `GET /api/v1/auth/me`. Instantly switches between "Sign in" CTA and `@handle` capsule + "Sign out" across all pages without manual reload.
- **In-App PWA Storefronts (`/[handle]`)**: Creator profiles stay entirely within the PWA, complete with live Follow/Unfollow, Vault tabs, and media.
- **In-App Direct UPI Pay Sheet & 12-Digit UTR Claim Modal**: Fans tap "Unlock" to reveal the creator's UPI ID, copy button, deep UPI intent links (GPay, PhonePe, Paytm), and 12-digit UTR input form hitting `POST /api/v1/payment_claims`.
- **In-App Vault Gallery Viewer**: Unlocked collections expand into a dedicated in-app photo and video lightbox without navigating away to the web app.
- **Pure Content Feed (`/feed`)**: Feed stream is dedicated strictly to content (Vault collection drops, photo/video posts, broadcast lives) from creators the fan follows. Empty state guides fans directly to Explore.
- **Explore Pill Subtabs (`/discover?tab=content|creators`)**: Two high-contrast pill subtabs ("Explore Content" and "Explore Creators") accompanied by horizontal category filters, allowing fans to browse drops or discover verified creators with 1-tap follow.
- **Development Service Worker Auto-Purge**: On `localhost`, service worker registrations and browser static script caches are automatically unregistered and purged to eliminate any hydration mismatches between Next.js compilation and cached client assets.

---

## 22. Nocturnal VIP Feed Screen & Vector SVG Iconography Standard

- **Pixel-to-Pixel Nocturnal VIP Experience (`/feed`)**:
  - **Header**: Tracked uppercase `WISHFUL ✦` logo with ruby sparkle, search vector icon, notification bell with unread dot, and creator avatar pill with glowing ruby ring.
  - **Creator Highlights Ring Tray**: Horizontal story circles with neon ruby pulse animation (`ANJALI ✦`), VIP badges, and touchable story viewer modal.
  - **Card Archetypes**:
    1. *Photo Post (Anjali Hegde)*: 4K Ultra HD tag, bottom glass sneak peek pill, quick reaction pills (`🔥 1.8k`, `🫦 1.1k`, `🍑 850`, `💘 620`), vector SVG action bar.
    2. *Interactive Poll (Kiara Roy)*: Real-time animated percentage bars (`68%` vs `32%`), final hours badge, vector SVG action bar.
    3. *The Vault Drop Album (Tara Kapoor)*: Cover preview with slide peek (`18 Ph...`), `PUBLIC PREVIEW` tag, glowing ruby `🛍️ UNLOCK VAULT DROP • ₹499 (DIRECT UPI)` button with instant UTR claim sheet.
    4. *Audio Whisper Drop (Rhea Sen)*: ASMR whisper tag, animated equalizer waveform, skip 15s vector controls, spatial binaural 3D & FLAC lossless tags.
    5. *Video Reel Teaser (Zara Velvet)*: 60fps Dolby Vision tag, audio mute toggle SVG, center play button, duration scrubber line, quick spicy reactions bar.
    6. *Locked Stream Replay (Kiara Roy)*: Replay archive stats, center lock insignia, direct unlock button at ₹299.
- **Dedicated Full-Page Post Viewer (`/feed?post=[id]`)**: Clicking any post card or comment button navigates to a dedicated single post page with a sticky header containing a `<` Back button, creator avatar with glowing pink star ring, verified checkmark badge (`✓`), and `+ Follow` action.
- **Dynamic Bottom Navigation Visibility**: The bottom navigation bar is automatically hidden on the single post view (`body.hide-bottom-nav`) and restored upon returning to the feed.
- **Constrained Bottom Comment Bar**: Strictly centered and constrained inside the 480px mobile PWA container (`max-width: 480px; left: 50%; transform: translateX(-50%); box-sizing: border-box;`), featuring 6 quick reaction emojis (`🔥`, `😈`, `🌶️`, `🫦`, `🪽`, `🎧`), avatar, rounded input field with smiley trigger, and electric ruby gradient send button.
- **4-Tab Nocturnal Bottom Navigation**: `FEED`, `VAULT`, `POST +`, `VIP` with tracked uppercase Plus Jakarta Sans typography.
 
---
 
## 23. Scalable Job Pipeline & High-Concurrency Social Architecture
 
To withstand viral spikes without database lock contention and ensure snappy client latency, Wishful employs an asynchronous event-driven architecture powered by Rails 8 Solid Queue and ActionCable:
 
1. **Async Event Pipeline (`TrackEventJob` in `:analytics`)**:
   - `EventTracker.track` is non-blocking by default. Event insertion into monthly partitioned PostgreSQL tables is offloaded to background workers.
   - Preserves synchronous execution (`EventTracker.track_sync`) for transactional flows requiring immediate event IDs (e.g. payment unlocks, follow feed backfill).
   - Monthly partition automation via `CreateMonthlyPartitionJob` creates future partition tables before month boundaries.
 
2. **Buffered Counters (`CounterBufferJob` in `:counters`)**:
   - Eliminated row-level lock storms on `creator_posts` caused by synchronous `counter_cache: true`.
   - Likes and comments enqueue asynchronous recount-and-update jobs via `after_create_commit` and `after_destroy_commit`.
   - Counters reflect accurate counts with sub-second eventual consistency.
 
3. **Asynchronous Notifications & Push (`NotifyJob` in `:messaging`)**:
   - In-app notification creation and Web Push delivery are deferred off the request thread.
   - Built-in deduplication (prevents notifying self) and localized copy formatting for likes, comments, follows, VIP passes, messages, drops, and live sessions.
 
4. **Intraday Analytics Accumulation (`ContentStatsAccumulatorJob` in `:analytics`)**:
   - Runs every 15 minutes to aggregate intraday events into `content_daily_stats`, `creator_daily_stats`, and `referral_daily_stats`.
   - Creators receive near real-time Studio metrics and sparklines without waiting for midnight cron jobs.
 
5. **Real-Time Messaging & Chat Scalability (`UpdateConversationJob` & ActionCable)**:
   - WebSocket broadcasts via `ConversationChannel` handle real-time message delivery, typing indicators, and read receipts without database writes.
   - `UpdateConversationJob` asynchronously increments unread message counters, updates conversation timestamps, tracks analytics, and notifies recipients.
   - `config/cable.yml` supports Redis Pub/Sub in production via `REDIS_URL` with Solid Cable fallback.

