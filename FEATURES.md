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
11. [Multi-Theme Visual Design System](#11-multi-theme-visual-design-system)

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

## 11. Multi-Theme Visual Design System ("Indian Modern Editorial Chic")

Wishful is built on the **Indian Modern Editorial Chic** design system, combining contemporary haute-couture editorial rigor with Indian sartorial luxury.

### Brand Aesthetic & Color Theory
- **Primary (`#C2185B` / `#9B0044` - Sindoor Ruby):** High-fashion crimson rose for primary actions, unlock states, active tabs, and priority micro-interactions.
- **Secondary (`#D4AF37` / `#735C00` - Zari Gold):** Refined metallic ochre reserved for VIP memberships, close friends tier markers, verified badges, and ceremonial tier indicators.
- **Tertiary (`#7A1C3C` / `#892847` - Deep Jamun / Velvet Maroon):** Grounded wine tone for deep container tints, elevated tags, and subtle gradient borders on exclusive drops.
- **Neutral (`#111317` / `#1A1C20` - Kajal Charcoal):** Deep carbon black delivering high contrast against the backdrop without sterile harshness.
- **Canvas Base (`#F6F7F5` / `#F9F9FF` - Raw Alabaster Silk):** Off-white, gallery-grade foundation that flatters South Asian skin tones and vivid textile photography.

### Typography Engine
- **Plus Jakarta Sans:** Drives creator display branding, collection titles, spotlight story intros, bio copy, Rupee pricing (`price-editorial`), metadata, navigation bars, and lock badges with geometric clarity.
- **₹ Glyph Standards:** The ₹ glyph renders at matching font weight and baseline height with numerical pricing.

### Elevation & Component Specs
- **Frosted Glass Cards:** Translucent white (`rgba(255, 255, 255, 0.78)`) with `backdrop-filter: blur(16px)` and a hairline border.
- **Locked Media Veil:** Gradient scrim over preview thumbnails with `backdrop-filter: blur(10px)`.
- **Zari Glow:** Soft luminescence on VIP tier cards (`box-shadow: 0 4px 20px -2px rgba(212, 175, 55, 0.25)`).
- **Sticky Mobile Checkout Drawer:** Pill-shaped mobile CTA anchored to the viewport base with instant UPI trigger.

### Creator Themes (`User::THEMES`)
1. **Minimal:** Raw Alabaster Silk (`#F6F7F5`), Bodoni display, Sindoor Ruby accents (`#C2185B`).
2. **Luxury:** Deep midnight navy palette (`#14142A`) with soft metallic rose accents (`#F0A9C8`).
3. **Adventure:** Earthy sage green tones (`#EDF1EA`) with deep forest green accents (`#0B5B42`).
4. **After Dark:** Jet black night aesthetic (`#0C0D10`) with neon pink glow (`#FF5C8A`).
5. **Atelier:** Haute-couture monochrome obsidian (`#050505`) with hot magenta highlight (`#E91E63`).

### 12. Mobile-First Editorial Fan Storefront Architecture
The public creator profile (`/@handle`) is engineered as an intimate 480px phone-first experience on desktop and 100% full-bleed on mobile viewports:
1. **Header App Bar**: Wishful ruby badge `(W)`, brand wordmark, pulsing green `• Live UPI` indicator, `Open App` button, and native share action.
2. **Editorial Cover Banner**: 16:9 full-bleed banner with frosted cover credit tag (`Cover: Banarasi Heritage BTS`).
3. **Avatar & Creator Identity**: 84px avatar with 3.5px white ring, ruby verified checkmark badge (`✓`), floating Instagram pill, Bodoni display name, inline ruby `@handle`, category & location chips, and highlighted `100% direct fan UPI.` bio note.
4. **Unified Stats & Actions Card**: 3-metric container (`DROPS`, `SUPPORTERS`, `Direct UPI INSTANT`) with dual follow/share pill buttons.
5. **Obsidian VIP Close Friends Hero Card**: Obsidian luxury container with gold border & zari luminescence, `★ EXCLUSIVE PASS` badge, `₹499/mo`, 3 tier perks with `▶` gold bullet markers, zero platform cut, and direct VIP join CTA.
6. **Sticky Segment Switcher**: Sticky tab bar navigating `🔒 The Vault`, `👗 Curated Fits`, `🎁 Spoil Me Wishlist`, and `About`.
7. **Anti-Leak Shield Active Banner**: Prominent champagne banner informing visitors of forensic buyer watermarking and server-side frosted previews.
8. **Vault Drop Cards**: 4:5 portrait cards with server-side blurred teaser, top metadata badges (`FEATURED DROP` / `4K Video • 6 mins`), center golden lock disc, editorial pricing, buyer `@handle` watermark notice, and Instant UPI Unlock action.
9. **Curated Recommendations Showcase ("CURATED BLOUSE CUTS & FITS")**: Highlighting apparel styling with thumbnails, quotes, prices, merchants, and direct shop links.
10. **Direct UPI Educational Guide**: Dark obsidian card explaining zero-fee personal VPA settlements and 12-digit UTR bank claims.
11. **Sticky Floating Mobile Drawer**: Viewport-anchored bottom pill bar featuring heart disc, creator patronage copy, and direct `Unlock Vault` button.

### 13. Creator Administrative Suite Portal Architecture (`/dashboard`)
The creator management portal is engineered as an uncluttered, modern editorial administrative suite matching the **Indian Modern Editorial Chic** system:
1. **Top Portal Navbar (`Wishful`)**: Ruby sparkle cluster (`✦`), Bodoni/Playfair wordmark, single-row segment navigation with active `Dashboard` in a Sindoor Ruby pill (`#C2185B`) and clean text links (`The Vault`, `Live Studio`, `Calendar Schedule`, `Messages & DMs`, `Payment Claims`), alongside a clean user pill with circular avatar, `@handle`, gold verified checkmark badge (`✔`), and minimalist logout door action.
2. **Pending P2P Claims Alert Banner**: Warm champagne card (`#FFFBE8`) notifying the creator of pending 12-digit UTR claims awaiting one-tap verification with direct `Review 3 Claims ➔` CTA.
3. **Creator Suite Hero Greeting**: `Namaste, [Name] ✪` with `@handle` badge, `Luxury Drape Atelier • Studio Dashboard & P2P Node` subtitle, rounded storefront URL copy pill (`wishful.app/@handle`), `View Storefront` trigger, and filled `● Live Studio` button. On mobile, condenses into a tailored creator card.
4. **4-Metric Performance Dashboard**:
   - `APPROVED UPI GROSS`: Large currency stat (`₹48,500`), +18% growth pill, 0% fee note, and smooth Ruby trend sparkline curve.
   - `VAULT DROPS`: Active drops count (`8 active drops`), total unlocks (`142 digital unlocks`), lock badge, and Ruby progress bar.
   - `VIP SUBSCRIBERS`: Member count (`34 members`), projected monthly income (`₹16,966 / mo projected`), star badge, and Zari Gold progress bar.
   - `AFFILIATE TAPS`: Click count (`184 clicks`), referral link count (`Across 6 referral links`), bag badge, and rose progress bar.
   - On mobile: Formatted as a 2x2 grid under the `PERFORMANCE SNAPSHOT • Last 30 Days` header.
5. **Streamlined Quick Actions Bar (`CREATOR LAUNCHPAD`)**: Single-row horizontal button bar replacing bulky creation matrices: `+ New Vault Drop`, `+ Add Curated Fit`, `+ Create VIP Tier`, `🎁 Wishlist Goal`, and `📝 Write Update`.
6. **Storefront Sync Segmented Tabs**: Pill-shaped segmented tabs for `Manage Drops & Vault (8)`, `Curated Outfits & Links (6)`, `VIP Tiers & Wishlists (2)`, and `Overview & Stats` alongside the `● LIVE STOREFRONT SYNC` real-time indicator.
7. **Active Vault Drops & Digital Sets Panel**:
   - Header with published drop badge, `Filter` pill, and `+ Publish Drop` ruby button.
   - Horizontal drop cards with 16:9 thumbnail photography, format tags (`4K Set`, `Video`), title, `Active` status badge, unlock/revenue analytics, prominent price (`₹499 Instant UPI`), `View Live` button, `Edit` button, and `⋮` actions menu.
   - On mobile: Formatted as compact cards with portrait thumbnails, top tags, and inline action buttons.
8. **Balanced 2-Column Suite**:
   - Left Card: `VIP Pass: Close Friends Tier` with `₹499/mo`, bulleted perks, 34 Patrons / monthly revenue projection, `Edit Tier Rules`, and `Manage Members`.
   - Right Card: `Wishlist: Diwali Heritage Silk Saree` with `68% funded` badge, heavy Ruby progress bar, `₹10,200 pledged / Goal ₹15,000`, and `Manage Goal`.
9. **Creator Bottom Actions & Engine Status**: Quick pill links for UPI & Settlement Settings/Nodes, Blocked Accounts (4), Support Concierge, and live node indicator (`Wishful P2P Settlement Engine v2.4 • Direct VPA Node`).
10. **Mobile Bottom Navigation & Luxury Footer**: Fixed 5-tab app bar on mobile (`Dashboard`, `The Vault`, `Studio`, `Messages`, `Settings`), and clean desktop footer.

---

### 14. Design Documentation & Visual Reference

All design specifications and current-state screenshots are maintained in the repository:

- **`DESIGN.md`**: Comprehensive design system specification including brand identity, color tokens, typography scale, spacing, elevation, shape system, component library, responsive viewport standards, and CSS architecture.
- **`docs/screenshots/`**: 10 full-page desktop screenshots (1280×683) covering every user-facing page:
  1. `01_landing_home.png` — Landing / Home Page (`/`)
  2. `02_sign_up.png` — Sign Up (`/sign_up`)
  3. `03_sign_in.png` — Sign In / Login (`/sign_in`)
  4. `04_dashboard.png` — Creator Portal Dashboard (`/dashboard`)
  5. `05_fan_profile.png` — Fan-Facing Profile / Storefront (`/@handle`)
  6. `06_schedule.png` — Calendar Schedule (`/schedule`)
  7. `07_live_studio.png` — Live Studio (`/lives/new`)
  8. `08_payment_claims.png` — Payment Claims (`/payment_claims`)
  9. `09_messages.png` — Messages & DMs (`/conversations`)
  10. `10_creator_settings.png` — Creator Settings (`/creator_settings`)
- **`.agents/rules/design_system.md`**: Machine-readable YAML design tokens for AI agent consumption.
