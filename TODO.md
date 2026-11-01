# Project Security & Anti-Theft Roadmap

This document tracks implemented security safeguards and upcoming improvements for creator identity and exclusive content protection.

---

## 🛡️ Completed Safeguards

- [x] **Backend-Only Frosted Teaser Previews** (`FrostedPreviewService`)
  - Server-side downsampling (80x80) + Gaussian blur (0x16) before delivery.
  - Raw unblurred image bytes are never sent over the wire to unauthenticated visitors or DevTools.
  - Caching in `tmp/cache/frosted_previews` with `ETag` and `Cache-Control`.
- [x] **Dynamic Visible Forensic Watermarking** (`ForensicWatermarkService`)
  - Dual-layer user-specific stamping:
    - Translucent angled center watermark (`@fan_handle • #fan_id`).
    - High-contrast footer attribution banner (`Licensed to @fan_handle (Fan #fan_id) • Wishful • YYYY-MM-DD`).
  - Embedded EXIF/IPTC metadata comments with licensee details.
  - Creator exemption: Creators downloading their own posts receive pristine un-watermarked originals.
  - Cached per `(blob.key, user.id)` for sub-15ms streaming.
- [x] **Client-Side Anti-Theft Shielding**
  - Transparent `.media-shield` overlay blocking direct right-click "Save Image As..." and drag-to-desktop.
  - `draggable="false"`, `oncontextmenu="return false;"`, and `pointer-events: none` on protected media.
  - License pill (`🔒 Licensed to @handle`) shown to buyers in UI.
- [x] **Identity Protection & Anti-Impersonation**
  - `RESERVED_HANDLES` validation in `User` model blocking system and staff handles (`admin`, `support`, `official`, `wishful`, `security`, `billing`, etc.).
  - Session Fixation protection via `reset_session` in `SessionsController#create`.
- [x] **Obsidian Velvet & Neon Ruby Design System**
  - Integrated `Plus Jakarta Sans` typography hierarchy with extreme weight contrasts and tracked `label-vip` cues (`0.14em`).
  - Defined nocturnal luxury palette: Pure Abyss (`#050406`), Neutral Violet Core (`#09080c`), Smoked Obsidian Velvet (`#0e0c12`), Electric Ruby (`#ff1767`), Deep Plum-Rose (`#9d174d`), Rose Quartz Bloom (`#fb7185`), and Alabaster Primary (`#fdf2f4`).
  - Implemented glowing radiant neon bloom buttons (`box-shadow: 0 4px 20px rgba(255, 23, 103, 0.35)`) and full pill silhouettes (`border-radius: 9999px`).
  - Synchronized across `fan-app/src/app/globals.css`, `public/assets/wf.css`, `AGENTS.md`, `REFERENCE.md`, and `FEATURES.md`.
- [x] **11-Component Mobile-First Fan Storefront Assembly**
  - Top bar with Wishful mark, brand text, pulsing green `• Live UPI` indicator, `Open App`, and clipboard/native share.
  - 16:9 full-bleed banner with frosted cover credit tag, 84px avatar with 3.5px white ring, ruby verified checkmark badge (`✓`), and Instagram pill.
  - Creator title in `Bodoni Moda` with inline ruby `@handle`, category & location chips, and bio with `100% direct fan UPI.` highlight.
  - 3-column stats card (`DROPS`, `SUPPORTERS`, `Direct UPI INSTANT`) with `+ Follow Updates` and `Share link (?ref=fan)` buttons.
  - Obsidian VIP Close Friends Hero Card (`#141419`) with gold hairline border, zari glow, `★ EXCLUSIVE PASS` badge, `₹499/mo`, bullet perks with `▶` gold markers, and `Join VIP Pass ➔` CTA.
  - Sticky tab switcher (`The Vault`, `Curated Fits`, `Spoil Me Wishlist`, `About`) and Champagne `Anti-Leak Shield Active` banner.
  - 4:5 portrait Vault drop cards with blurred teasers, center golden lock disc, duration badges, and `Instant UPI Unlock >` action.
  - Curated Blouse Cuts & Fits showcase, Educational Direct UPI Unlocks guide card, and viewport-anchored bottom floating drawer.
- [x] **Uncluttered Creator Administrative Suite Rebuild (`/dashboard`)**
  - Designed according to modern editorial chic standards without visual clutter.
  - Implemented clean `✦ Wishful` top bar with ruby sparkle cluster, active `Dashboard` in a Sindoor Ruby pill, plain text nav items, and a streamlined user capsule (`@handle` + gold verified badge) with minimalist logout door icon.
  - Added pending P2P claims banner (`₹1,797 waiting verification`) with direct `Review 3 Claims ➔` modal/action.
  - Styled `Namaste, [Creator] ✪` hero greeting with storefront URL clipboard pill, external view trigger, and live broadcast studio launch.
  - Consolidated 4-metric real-time matrix with custom Ruby trend sparkline, progress bars, and mobile 2x2 grid.
  - Streamlined `⚡ Quick Actions` horizontal bar (`+ New Vault Drop`, `+ Add Curated Fit`, `+ Create VIP Tier`, `🎁 Wishlist Goal`, `📝 Write Update`).
  - Added storefront sync segmented tabs (`Manage Drops & Vault`, `Curated Outfits & Links`, `VIP Tiers & Wishlists`, `Overview & Stats`) with `● LIVE STOREFRONT SYNC`.
  - Built horizontal drop rows in `Active Vault Drops & Digital Sets` with 16:9 thumbnails, tags, unlock metrics, prominent `₹499 Instant UPI`, `View Live`, `Edit`, and `⋮` actions menu.
  - Built balanced 2-column bottom suite: VIP Close Friends pass card and Diwali Silk Saree Wishlist progress card.
  - Built full mobile adaptation with `Wishful STUDIO`, `CREATOR LAUNCHPAD`, stacked cards, and fixed 5-tab bottom navigation (`Dashboard`, `The Vault`, `Studio`, `Messages`, `Settings`).
- [x] **Comprehensive Design Reference & Page Screenshots (`DESIGN.md` + `docs/screenshots/`)**
  - Created `DESIGN.md` at repo root with full design system spec: brand identity, color tokens, typography scale, spacing, elevation, shape system, component library, responsive viewport standards, and CSS architecture.
  - Captured and saved 10 full-page desktop screenshots (1280×683) into `docs/screenshots/`: Landing, Sign Up, Sign In, Dashboard, Fan Profile, Schedule, Live Studio, Payment Claims, Messages, and Creator Settings.
  - Screenshots embedded in `DESIGN.md` with relative paths for portable viewing.

- [x] **Scalable Async Event & Social Architecture (5 Phases)**
  - **Phase 1: Real-Data Wiring**: Removed all hardcoded demo padding (`184+`, `91816+`) from `SubscribersController`. Integrated `creator_daily_stats` rollups into `DashboardController#show` with fallback to live claims queries.
  - **Phase 2: Asynchronous Event Pipeline**: Implemented `TrackEventJob` in `:analytics` queue. Refactored `EventTracker` to fire-and-forget async by default with sync fallback for critical callbacks. Added `CreateMonthlyPartitionJob` for monthly partition table maintenance.
  - **Phase 3: High-Concurrency Social Action Buffering**: Replaced synchronous `counter_cache: true` on `CreatorPostLike` and `CreatorPostComment` with asynchronous `CounterBufferJob` in `:counters` queue to prevent row-lock storms during viral traffic. Wired `NotifyJob` in `:messaging` queue and `IncrementFanProfileJob` in `:analytics` queue.
  - **Phase 4: Real-Time Messaging & Chat Scaling**: Built `UpdateConversationJob` for async notification and event tracking on direct messages. Added typing indicators and read receipts to `ConversationChannel`. Configured production ActionCable to support Redis Pub/Sub via `REDIS_URL` with Solid Cable fallback.
  - **Phase 5: Cron & Job Scheduling**: Configured `config/recurring.yml` with Solid Queue recurring tasks for nightly `DailyAnalyticsRollupJob` (2 AM IST), nightly `FanProfileRecalculateJob` (3 AM IST), 15-minute `ContentStatsAccumulatorJob`, and 25th-of-month `CreateMonthlyPartitionJob`.

- [x] **Installable Next.js + Workbox PWA Fan App (`fan-app/`)**
  - Standalone mobile-first fan PWA with offline Workbox service worker (`sw.js`), web manifest, and Dark Studio tokens.
  - In-app creator profile storefronts (`/[handle]`) with live follow toggle, tabs, and media previews.
  - In-app direct UPI pay sheet with QR/UPI ID copy, deep UPI intent links, and 12-digit UTR claims (`POST /api/v1/payment_claims`).
  - In-app unlocked Vault gallery viewer modal with DRM watermarked media.
  - In-app Explore tab (`/discover`) with dual pill subtabs ("Explore Content" and "Explore Creators") and horizontal category filters.
  - Personalized Fan Feed (`/feed`): Scoped strictly to followed creators with instant follow sync in `Api::V1::CreatorsController#follow` and clean purge on unfollow.
  - Comprehensive creator content enrichment: Seeded 160+ active posts with media across all 53 creators and 11 live Vault collections with frosted previews and prices.
  - Dynamic client-side auth synchronization in `Header.tsx` subscribing to `wf_auth_change` and `storage` events with automatic validation against `GET /api/v1/auth/me`.
  - Pure content feed stream (`/feed`) displaying only collection drops, posts, and live sessions from followed creators.
  - Explore page (`/discover`) with "Explore Content" and "Explore Creators" pill-type subtabs and dynamic category filtering.
  - Dedicated Full-Page Post Viewer (`/feed?post=[id]`): Replaces modal overlays with a dedicated view page featuring sticky header, Back button (`<`), creator follow action, and dynamic bottom navigation hiding (`body.hide-bottom-nav`).
  - Mobile PWA Constrained Bottom Comment Bar: Locked strictly inside the 480px mobile container (`max-width: 480px; left: 50%; transform: translateX(-50%); box-sizing: border-box;`), featuring 6 quick reaction emojis (`🔥`, `😈`, `🌶️`, `🫦`, `🪽`, `🎧`), avatar, rounded input field with smiley trigger, and electric ruby gradient send button.
  - Streamlined Content Feed: Removed redundant category filter pills on top of `/feed` ("ALL", "SPICY DROPS", etc.) for an uninterrupted story-to-cards timeline.
  - Development Service Worker hygiene: unregisters service workers and purges `wf-static` caches on localhost to prevent stale script caching and hydration errors.

  - Studio sidebar app: Overview, Posts, Collections + editor, Shop, Link lists, Book (week calendar), Payments, Messages (three panes), Settings; phone live studio.
  - Link lists (`LinkList`, `LinkListItem`): public page, counted taps, list attribution on payments, editor with preview and sharing, QR download.
  - Phone + WhatsApp OTP accounts and four-step creator onboarding (`OtpCode`, `OtpController`, `OnboardingController`, `WhatsappClient`).
  - Installable PWA: manifest, icons, service worker with offline unlocks, install prompt, Web Push (`PushSubscription`, `WebPushNotifier`, `Notifier`).
  - Screenshots in `docs/screenshots/redesign-2026-10/`.
- [x] **Light theme (14 Oct 2026)**: Dark / Light / System per viewer (`wf_theme` cookie, `ThemesController`, `shared/_theme_switch`); light tokens in `wf.css`; photo and video surfaces stay dark.
- [x] **Scalable Database Architecture & Event Sourcing (14 Oct 2026)**:
  - Range-partitioned `events` table (monthly) capturing all actions (views, unlocks, likes, comments, shares, tips).
  - Nightly rollup tables (`creator_daily_stats`, `content_daily_stats`, `referral_daily_stats`) via `DailyAnalyticsRollupJob` for zero-scan Studio dashboard queries.
  - Fan engagement scoring & tiers (`fan_profiles`) with composite weighting for spend, unlocks, CF months, and activity tiers (`whale`, `super_fan`, `regular`, `casual`, `lurker`).
  - Real-time counter caches on `users`, `paid_media_collections`, `paid_media_posts`, `creator_posts`, `link_lists`, `live_sessions`.
  - In-app notification inbox (`notifications`) with read/unread tracking.
- [x] **Fan Feed & Discovery Engine (14 Oct 2026)**:
  - Fan-out on write (`feed_items`, `FeedFanoutJob`) delivering instant reverse-chronological timelines.
  - High-res collection covers featured as organic purchase funnels with direct unlock CTAs.
  - Instant backfill on follow (top 5 drops) and instant purge on unfollow.
  - Discovery & Explore surface (`/discover`) with trending albums, creator categories, and live announcements.
  - Curated discovery fallback stream when fans follow 0 creators or browse as guests.
- [x] **Feed Tab Real APIs & Social Interactivity (14 Oct 2026)**:
  - Built `Api::V1::PostsController` (`GET /api/v1/posts/:id`, `POST/DELETE /api/v1/posts/:id/like`, `POST/DELETE /api/v1/posts/:id/save`).
  - Built `Api::V1::PostCommentsController` (`GET/POST /api/v1/posts/:id/comments`) with VIP pass detection and creator verification badges.
  - Created `post_bookmarks` table & model with unique indexes for fan post saving.
  - Enriched `Api::V1::FeedController` with full archetype serialization (photos, runway polls, audio notes, video teasers, streams, collections).
  - Fixed client-side UPI claim endpoint in `feed/page.tsx` (`POST /api/v1/payment_claims` with `purchasable_type: 'PaidMediaCollection'`).
  - Connected Next.js PWA Feed timeline to live Rails API with optimistic UI updates and server synchronization.
- [x] **Nocturnal VIP Feed Screen & Vector SVG Iconography Standard (14 Oct 2026)**:
  - Pixel-to-pixel reconstruction of mobile feed: `WISHFUL ✦` header, search SVG, bell SVG with unread dot, and profile avatar ring.
  - Glowing horizontal highlights row (`ANJALI ✦` with video camera SVG and neon ruby ring, `TARA`, `ZARA`, `RHEA VIP`, `KIARA`).
  - 4 Category filter pills (`ALL`, `SPICY DROPS 🔥`, `PRIVATE TEASERS 🔒`, `CLOSE FRIENDS VIP ⭐`).
  - 6 Rich Card Archetypes: Photo post with 4K UHD badge & sneak peek banner; Interactive runway poll with live percentage animations; Locked Vault Drop with slide peek & UPI unlock; Audio whisper drop with animated waveform equalizer & 15s skip controls; 60fps video teaser with mute toggle SVG & reactions; and Candlelit bedroom stream replay with lock insignia.
  - Dedicated Post View Page with top sticky header, Back button (`<`), creator follow button, full discussion thread, and bottom comment composer (replaces popup modals).
  - Bottom navigation bar dynamically hidden on single post view screen and strictly constrained to the 480px PWA mobile container.
  - 4-tab nocturnal bottom navigation (`FEED`, `VAULT`, `POST +`, `VIP`).
- [x] **Google Stitch 4-Screen Pixel-Perfect Implementation (15 Oct 2026)**:
  - Pixel-to-pixel reconstruction of all 4 Google Stitch screens from project `3128119346421041736` (`Creator MarketPlace`):
    1. **Posts & Content Analytics (`/creator_posts`)**: Fixed `w-[260px]` sidebar with live UPI status & user card, header with ⌘K search, 4 KPI cards (Total Posts, Impressions, Avg. Engagement Rate, Media Retention), segmented tabs, rich content inventory table (with thumbnail badges, reach ratios, likes/comments counters, action buttons), and CSV export.
    2. **Create Post Studio (`/creator_posts/new`)**: Editorial page header with auto-save cue, 5-type tabs (`Text & Story`, `Photo Set`, `4K Reel / Video`, `Audio Whisper`, `Interactive Poll`), editorial title, WYSIWYG formatting toolbar, narrative caption with live 2,200 character counter, media gallery with drag & drop upload & mosaic cards (Cover, RAW, DNG badges), interactive community poll with options 01 & 02, wardrobe & sourcing product credits, right sticky column with Access & Audience, Publish Cadence, Creator Controls toggles (Pin, VIP Whisper, Dynamic Forensic Watermark), and radiant neon-bloom CTA button.
    3. **Collections & Vault (`/paid_media_collections`)**: Vault Engine 4.2 header with direct P2P settlement indicator, search & revenue sort, 3 KPI cards (Total Gross Vault Revenue ₹3,24,500, Active Vault Inventory with circular SVG completion meter, Top Converting Bundle), segmented filter pills, 2-column inventory grid with locked cards, prices, and DRM indicators, Direct UPI P2P Settlement Guarantee banner (0% platform cut, < 2.4s SLA, creator VPA), and `#createDropModal` for publishing new PPV vault drops.
    4. **Subscribers & VIP Patrons (`/subscribers`)**: Patronage architecture header with CSV export & "+ Create VIP Tier" button, 3 KPI summary bento cards (Total Active Patrons 184, Monthly Recurring Revenue ₹91,816, Member Retention 96.4%), 3 active VIP tier cards (Close Friends Pass ₹499/mo, Inner Circle ₹999/mo, Sultan Patron ₹2,499/mo), and Patrons roster master table with filter tabs (All, Active, Expiring Soon), handle/UTR search, UTR verification status pills, direct messaging actions, and minimalist pagination.
  - Extracted shared studio partials: `app/views/layouts/_studio_head.html.erb`, `app/views/layouts/_studio_sidebar.html.erb`, `app/views/layouts/_studio_header.html.erb`.
  - Added dedicated route `GET /subscribers` (`SubscribersController#index`) and verified all 4 screens in browser subagent with full visual fidelity.
- [x] **Creator Studio Production SaaS UI Cleanup & Prototype De-Mocking (15 Oct 2026)**:
  - Eliminated "AI designed prototype" look and feel across all 4 Creator Studio views without altering the brand design system:
    - **Header & Sidebar**: Unified typography across active and inactive navigation items (`text-[13.5px]`), added structural hairline borders (`border-r border-white/[0.06]`), and styled active tab highlights with restrained glowing pill borders.
    - **Post Composer (`/creator_posts/new`)**: Removed hardcoded prefilled narrative titles and captions in favor of clean placeholder states; replaced fake static 3-image mosaic with a functional drag-and-drop file picker that reads real file metadata (name, size in MB) and previews uploaded media; made the interactive poll and product tagging accordions collapsible with clean blank states.
    - **Posts & Analytics (`/creator_posts`)**: Integrated instant client-side tab filtering (`All Posts`, `Photo Sets`, `4K Reels`, `Audio`, `Polls`) and real-time live search across posts.
    - **Collections & Vault (`/paid_media_collections`)**: Replaced amateurish diagonal clipped CSS ribbon (`rotate-45 BESTSELLER`) with an elegant, restrained top-right pill badge (`bg-primary/10 border border-primary/30 text-primary text-[10px]`); added working category filtering pills and real-time search; connected functional file input to `#createDropModal` with live file preview.
    - **Subscribers & VIP Patrons (`/subscribers`)**: Replaced frantic `animate-ping` pulsing dot with a refined, calm status pill (`Renewal Due (2d)` in soft amber); added live tab filtering (`All`, `Active`, `Expiring Soon`), instant patron search by handle/UTR, and live count indicator.
    - **Structural Contrast**: Introduced subtle hairline borders (`border-white/[0.06]`) and backdrop blurs across all KPI bento cards, data tables, and modal sheets to eliminate flat, washed-out surfaces on deep dark canvases.
- [x] **Overview / Console Page Pixel-to-Pixel Reconstruction (`/dashboard`, 15 Oct 2026)**:
  - Transformed `/dashboard` (`app/views/dashboard/show.html.erb`) to 100% pixel-to-pixel fidelity matching the Stitch Overview & Console design:
    - **Header & Atelier Node**: Breadcrumb `Studio > Console`, `ATELIER INTELLIGENCE • LIVE SETTLEMENT NODE / Direct P2P Architecture` tag with ruby dot, greeting `Welcome back, Aura ✨`, statement export CSV, and `+ Quick Action` pill.
    - **4-Metric Bento Row**: Monthly Net Revenue (₹4,16,316, +21.4% vs last month, 100% Direct UPI P2P, 0% PLATFORM FEE), Total Active Patrons (184 Members, ↑ +14 this billing cycle, VIP Retention 96.4%), Vault Drop Unlocks (342 Unlocks, ₹3,24,500 gross yield, Active Circulation 8 Drops), and Feed & Media Reach (482.5K Views, 16.8% avg engagement, Studio Tier TOP 0.1%).
    - **Pending Verifications**: Gradient plum-wine banner for `3 Pending Direct UPI Verifications` (`₹1,797 TOTAL`) with instant `Review & Match UTRs ➔` CTA.
    - **Live Patron Transaction Ledger**: Real-time connected table with live stream indicator (`● LIVE STREAM CONNECTED`), detailed columns (`PATRON`, `DROP / ACCESS PASS`, `AMOUNT`, `SETTLEMENT RAIL`, `TIMESTAMP`, `ACTION`), and real-time ledger items (KX @kabir_x, DM @dev_mumbai, PS @priyastyles).
    - **Top Performing Vault Drops**: 2 showcase drops ("The Royal Noir Collection" 44 Photos 4K with ₹1,10,926 gross, and "Golden Hour in Goa" 18 Clips 60 FPS with ₹43,912 gross) with direct `Edit Drop` and `View all 8 drops ➔` controls.
    - **Right Column Suite**: Fast Lane Creator Actions 2x2 grid (`+ Create Feed Post`, `+ New Vault Drop`, `Schedule Live`, `Curate Sourcing`), Upcoming Scheduled Drop ("Velvet Mirage (Teaser Live)" with `TONIGHT` badge and 11:59 PM IST reminder), and Direct UPI Settlement Node with active VPA (`aura@okhdfcbank`), NPCI 2.4s SLA, and gateway settings action.
- [x] **Live Broadcast Scheduling & On-Air Studio Suite (`/lives/new`, `/lives/:id/studio`, 15 Oct 2026)**:
  - **Broadcast Scheduling & Incentive Goal (`/lives/new`, `LiveSessionsController#new/create`)**:
    - Breadcrumb `STUDIO > LIVE BROADCAST > SCHEDULE` with `DIRECT RTMP/UPI` badge.
    - **Step 01 (Broadcast Session Details)**: Stream Title with 80-char counter, Markdown VIP teaser description, Scheduled Date/Time with `PEAK FAN SLOT` badge, and interactive duration selector pills (`30m`, `45m`, `60m`, `Open`).
    - **Step 02 (Admission & Audience Access)**: 3-tier selectable gatekeeper cards (`Public Teaser + VIP Transition`, `VIP Patrons Only` selected default, `Ticketed PPV Live` at ₹299).
    - **Step 03 (Direct Stream Ingest & OBS Setup)**: Ingest switcher (`Browser Cam` vs `OBS / RTMP Pro`), copyable RTMP endpoint (`rtmps://live.wishful.app/live`), masked stream key with visibility toggle & one-click copy, and automatic paywalled replay vaulting toggle.
    - **Live Incentive Goal**: Fan crowd-funding meter toggle, goal target amount (`₹10,000` with ₹2.5k / ₹5k / ₹10k / ₹25k presets), milestone action reward, 3-tier unlock triggers (VIP Audio, Silhouette Costume Swap, Main Drape Reveal), and 64% simulated HUD momentum bar.
    - **Interactive Controls & Moderation**: Pay-to-Chat Tip Gate (`Min ₹50`), Chat Pace Regulation (`10s Delay`), Discreet Fan Watermark toggle, and VIP Alert Dispatch.
    - **Past Broadcasts Archive Drawer**: Modal listing completed past live sessions with direct studio inspection triggers.
  - **Live Broadcast Studio On-Air (`/lives/:id/studio`, `LiveSessionsController#studio`)**:
    - **Telemetry Header**: Glowing `● ON AIR / 00:44:14` timer badge, broadcast title with verified badge, `1,842 VIPs` viewer chip, `₹18,450.00` Instant UPI (0% fee) chip, `1080p60 • 6,200 kbps • 0 drops` stream health indicator, and `End Broadcast` call termination action.
    - **UltraHD Video Stage**: Nocturnal luxury stream simulation with animated `WHISPER EQ ACTIVE` audio spectrum, `WISHFUL FORENSIC WATERMARK ACTIVE` shield badge, camera lens indicator (`Lens: Sony FE 50mm f/1.2 GM`), and floating glass control dock (Mic, Video, `Studio ASMR` radiant pill, PIP, and Audio Settings).
    - **Milestone Goal Meter**: Radiant ruby progress bar (`74% Reached`), remaining milestone yield calculation, and recent tipper badges (`+₹500 @kabir_x`, `+₹200 @rohit_v`).
    - **VIP Chat Stream**: Pay-to-Chat (`₹50+`) tab switcher (`All Messages (89)` vs `Tips Only (24)`), styled patron chat cards with VIP badges & instant tip highlights, and pinned Host Priority announcement composer.
- [x] **Creator 3-Pane Messaging & VIP Desk Suite (`/conversations`, `/conversations/:id`, 15 Oct 2026)**:
  - Transformed the creator messaging interface (`app/views/conversations/studio.html.erb`) into a high-end 3-pane desktop workspace matching the Stitch specifications:
    - **Sidebar Integration**: Added active radiant electric ruby highlight on `Messages & DMs` with unread notification badge `3`.
    - **Pane 1 (Inbox List)**: `Messages` header with `VIP DESK` badge, `+ Broadcast` action, filter tabs (`All (24)`, `VIP (18)`, `DMs (6)`, `Unread (3)` in ruby), real-time thread search, rich patron preview rows with VIP badges (`TOP 0.1%`, `₹500 TIP`, `PATRON • VIP PASS`, `BROADCAST • 184 PATRONS`), and P2P instant gateway status indicator.
    - **Fan About Info & Patron Intel Drawer**: Toggled on-demand via the three-dot (`more_vert`) menu in the chat header with a close button (keeping the default conversation workspace spacious, focused, and uncluttered): displays location (`Bandra West, Mumbai`), tier (`Tier 3 VIP / Inner Circle`), total Direct UPI volume card (`₹18,450`, 100% P2P settled), verified UPI ID (`kabir@oksbi`), quick creator actions (`Send Private Vault Drop`, `Create 1:1 Booking Slot`, `Custom Price Quote`), and recent unlock activity.

---

## 🧭 Redesign follow-ups

- [ ] **Install ImageMagick in every environment** (`sudo apt install imagemagick` in WSL). Without it `ForensicWatermarkService` serves unlocked images *unwatermarked* and teasers fall back to an SVG. Consider failing closed (refuse to serve) instead of falling back.
- [ ] **Configure a WhatsApp provider** (`WHATSAPP_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`, approved `WHATSAPP_OTP_TEMPLATE` and `WHATSAPP_NOTICE_TEMPLATE`). Until then OTPs only reach the log. Add an SMS fallback ("Send by SMS" is in the design but not built).
- [ ] **Set VAPID keys in production** (`VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`); development generates `storage/vapid.json`.
- [ ] **Rate-limit OTP sends per IP and per number** (only a 30-second per-number throttle exists today).
- [ ] **UPI payee-name verification**: the onboarding "name on this UPI ID" is typed by the creator; the design implies a bank lookup, which needs a PSP API.
- [ ] **Instagram import** at onboarding (design 6c) is not built; it needs the Instagram Graph API.
- [ ] **Post scheduling** (design 5e "Schedule") is not built; posts are draft or published.
- [ ] **Automated tests** for OTP, onboarding, pay flow, link lists and the media authorisation rules (the app has no test suite yet).
- [ ] **Old stylesheets** (`profile.css`, `dashboard.css`, `live.css`) are no longer used by the redesigned screens; remove once no legacy page references them.

---

## 📋 Security & Anti-Theft TODO

### High Priority

- [ ] **Invisible Digital Fingerprinting (Steganography)**
  - Embed subscriber identity (user ID + payment reference hash) into high-frequency pixel noise (DCT / LSB steganography).
  - Ensures traceability even if a leaker crops out the footer banner, applies color grading, or attempts AI watermark removal.
- [ ] **HLS Segmented Streaming for Video Drops**
  - Replace direct `.mp4` downloads with chunked HLS streaming (`.m3u8` playlist with 2–4s `.ts`/`.m4s` segments).
  - Protect chunks with short-lived (30-second TTL) HMAC-signed authorization tokens tied to the user's session.
  - Prevent one-click browser/downloader extensions from ripping whole video files.
- [ ] **Forensic Watermarking for Video Media**
  - Integrate `ffmpeg` burn-in watermark filter into the video transcode background pipeline (`SolidQueue` / ActiveJob).
  - Dynamically or asynchronously generate video drops with subscriber watermarks.

---

### Medium Priority

- [ ] **DOM Protection via HTML5 Canvas / WebGL Player**
  - Render unlocked images into an HTML5 `<canvas>` via blob memory buffers rather than standard `<img>` tags.
  - Completely hides image URLs and intrinsic sizes from DOM tree inspection.
- [ ] **Screen Capture & DevTools Deterrence**
  - Use Page Visibility API to blank or blur the canvas when the browser window loses focus or when a screen-sharing session is detected.
  - Block keyboard shortcut events for screenshotting (e.g. `PrintScreen`, Cmd+Shift+3/4 warnings where detectable).
- [ ] **Scraping & Bulk Download Rate Limiting**
  - Implement per-user download velocity limits on `/paid_media_posts/:id/media` (e.g., max 5 media fetches per minute).
  - Alert creators and flag accounts downloading an entire catalog within seconds.
- [ ] **Geo & Concurrent Session Anomaly Detection**
  - Flag or freeze accounts attempting concurrent media access from different geographic IP ranges simultaneously (preventing credential sharing across leak rings).

---

### Operations & Legal

- [ ] **Terms of Service & Redistribution Deterrence Notice**
  - Add explicit clause in ToS: *"All exclusive vault media is forensically watermarked with your account ID. Redistribution on third-party forums/channels triggers immediate account termination and forfeiture of all subscriptions."*
  - Display a one-time modal acknowledgment before a fan's first vault media view.
- [ ] **Automated Leak Monitoring & Crawler**
  - Set up scheduled monitoring/reverse image hash matching against common leak platforms (Telegram, Reddit, Discord).
  - Automated revocation and ban workflow triggered by matching watermarked subscriber IDs.
