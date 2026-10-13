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
- [x] **Payment Bypass Closure**
  - Restricted test-mode purchase actions (`paid_media_posts#purchase`, `contact_reveals#purchase`, `subscription_plans#subscribe`) strictly to `development` and `test` environments.

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
