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
- [x] **Indian Modern Editorial Chic Design System**
  - Integrated `Plus Jakarta Sans` typography hierarchy across public profiles and layouts.
  - Defined subcontinental luxury palette: Sindoor Ruby (`#C2185B` / `#9B0044`), Zari Gold (`#D4AF37`), Deep Jamun (`#7A1C3C`), Kajal Charcoal (`#111317`), and Raw Alabaster Silk (`#F6F7F5`).
  - Saved full design system tokens, layout, spacing, elevation, shapes, and components to `.agents/rules/design_system.md` and memory.
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
