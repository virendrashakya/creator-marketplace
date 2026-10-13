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

## 11. Multi-Theme Visual Design System

Creators can customize their public page aesthetic with 5 hand-crafted themes:

1. **After Dark** (`#0C0D10`, hot pink `#FF5C8A` accent): Night-club neon aesthetic, high-contrast dark mode tailored for VIP content and late-night drops.
2. **Atelier** (`#050505`, electric crimson `#E91E63` accent): Editorial high-fashion aesthetic featuring Playfair Display typography.
3. **Minimal** (`#F4F5F3`, deep berry `#C2185B` accent): Clean, modern Scandinavian simplicity with light gray card surfaces.
4. **Luxury** (`#14142A`, pastel pink `#F0A9C8` accent): Deep midnight navy palette with soft metallic rose accents.
5. **Adventure** (`#EDF1EA`, forest green `#0B5B42` accent): Earthy sage green tones designed for travel and outdoor creators.
