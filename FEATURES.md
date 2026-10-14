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

## 11. Dark "Studio" Design System (Oct 2026 redesign)

The light "Indian Modern Editorial Chic" theme and the five per-creator themes were replaced by a single dark system, ported from the Claude Design files (Fan App, Creator Dashboard, Link Lists, Onboarding, PWA and States). The theme column is kept but no longer changes the storefront.

- **Stylesheet**: `public/assets/wf.css`, `w-` prefixed classes. The older `wishful.css` still loads underneath, and `wf.css` re-points its tokens so long-tail create/edit forms render dark inside Studio.
- **Palette**: page `#0E0E10`, cards `#16161A`, lines `#26262A`, text `#F5F5F7` / `#A1A1AA`; ruby pink `#E0306A` for the paid action; gold `#F5B942` for Close Friends and anything already yours; green `#4ADE80` for money that has landed; rose `#F87196` for errors.
- **Type**: Plus Jakarta Sans throughout.
- **Icons**: stroke icons lifted from the design files, rendered by `WfHelper#wf_icon`.
- **Chromes**: `fan` (phone-width app), `list` (link-list page), `studio` (creator sidebar app), plus the unchanged `marketing` and `bare`.
- **Light theme**: each viewer chooses Dark (default), Light or System from the Studio sidebar, Settings, or the fan top bars. It's stored in a cookie, so signed-out fans can choose too, and it's applied before paint. Photo and video surfaces (viewer, live room) stay dark in both themes.

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

## 14. Creator Studio

Sidebar web app: Overview, Posts, Collections, Shop, Link lists, Book, Payments, Messages, Settings.

1. **Overview**: earned this month (vs last), collection unlocks, Close Friends members and monthly value, link-list opens/taps; earnings chart (7D/30D/90D) by source; "Needs you" list; top collections.
2. **Payments**: Waiting / Approved / Rejected / All, stats (waiting, approved this month, rejected, average time to approve), CSV export, Approve / Reject / "Ask ₹N" for short payments (opens a DM), mismatch rows flagged.
3. **Collections + editor**: grid with Live / Draft / Scheduled; editor with multi-file upload, drag to reorder (first = public cover), price, release date, Close Friends / downloads / show-on-profile switches, preview.
4. **Posts**: grid + composer (media, caption, link a collection, draft or post now).
5. **Shop**: affiliate links with taps, categories.
6. **Book**: week calendar of calls, lives and open slots; switches for what fans can book.
7. **Messages**: three panes: inbox (All / Close Friends / Unread), thread with "Paid media" cards, fan panel (spent, collections owned, Close Friends since, last gift, Block).
8. **Settings**: profile, socials (incl. blog), UPI payouts (backup UPI, QR, auto-approve exact matches under ₹N, WhatsApp alerts), Close Friends plans, Spoil Me lists, account.
9. **Live studio** (`/lives/:id/studio`): phone-first room with Go live / End, chat, share link and a room-controls sheet.

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

## 18. Design Documentation & Visual Reference

- `docs/screenshots/redesign-2026-10/`: 18 screenshots of the redesign (fan screens at 390px, Studio at 1440px, desktop storefront and link list at 1280px).
- `DESIGN.md` and `docs/screenshots/01_…10_…` describe the previous light design and are kept for history.
