# Wishful — Ongoing Task & Handover Guide (Cross-Machine Continuity)

> **Purpose:** Read this document first when continuing work on Wishful from another computer, environment, or clean checkout. It summarizes the current state, active tasks, exact startup commands, credentials, and next backlog items.

---

## 📌 Executive Summary & Current State

Wishful is a mobile-first creator storefront, Studio administration suite, and Next.js PWA where Indian creators (saree drapers, glamour & fashion models, GRWM, lifestyle creators) monetize directly via peer-to-peer UPI (0% platform rake) with forensic DRM watermarking.

### What Was Just Completed in This Session:
1. **Studio Screens Pixel-to-Pixel Refinement (Obsidian Velvet & Neon Ruby)**:
   - **Console / Overview** (`/dashboard`): 4-KPI bento matrix, pending claim verification rail, live stream card, patron ledger, top drop performance, and sparklines reading from daily rollups with live fallback.
   - **Posts & Content Analytics** (`/creator_posts`): Content filtering (photo, video, audio, poll), creation modal with custom tabs, metric bar, and CSV export.
   - **Vault & Collections** (`/paid_media_collections`): Grid with status filters, pricing badges, 12-digit UTR claims counter, item management & reordering.
   - **VIP Patrons & Subscribers** (`/subscribers`): Real database metrics (zero hardcoded padding), churn rates, MRR, Close Friends pass breakdown.
   - **Live Broadcast Studio** (`/lives`): Scheduler modal, WebRTC stream stage simulation, milestone meter, and pay-to-chat VIP stream.
   - **Conversations & Fan Chat** (`/conversations`): 3-pane real-time chat with typing indicators, read receipts, and collapsible fan dossier drawer.

2. **Scalable High-Concurrency Architecture (All 5 Phases Finished)**:
   - **Phase 1 (Zero Hardcoding)**: `SubscribersController` and `DashboardController` query real database rows and `creator_daily_stats` rollups.
   - **Phase 2 (Async Event Sourcing)**: `TrackEventJob` in `:analytics` queue, non-blocking `EventTracker.track`, auto-partitioning via `CreateMonthlyPartitionJob`, and intraday 15-min rollups via `ContentStatsAccumulatorJob`.
   - **Phase 3 (Social Action Buffering)**: Replaced row-locking `counter_cache: true` with debounced `CounterBufferJob` in `:counters` queue on likes and comments. Wired `NotifyJob` and `IncrementFanProfileJob`.
   - **Phase 4 (Chat Scaling & WebSockets)**: `ConversationChannel` WebSocket broadcasts typing indicators and read receipts. `UpdateConversationJob` runs off the request path in `:messaging` queue. `config/cable.yml` configured for production Redis adapter with Solid Cable fallback.
   - **Phase 5 (Cron & Background Queues)**: Configured `config/recurring.yml` for Solid Queue recurring tasks. Added migration `20261101000000_create_solid_queue_tables.rb` so Solid Queue, Cable, and Cache tables migrate automatically anywhere.

3. **Next.js 16 Fan PWA (`fan-app/`)**:
   - Installable PWA with Workbox service worker caching and offline access.
   - Nocturnal VIP feed (`/feed`) with interactive cards (photos, video reels, audio whispers, polls, vault albums).
   - Dedicated full-page post viewer with comment thread, quick reactions, and hidden bottom nav.
   - Discover page (`/discover`) with dual subtabs (Content vs Creators).

---

## 🛠️ Step-by-Step Setup on Another PC

### 1. Prerequisites
- **macOS or Linux / WSL (Ubuntu 22.04+)**
- **Ruby 3.4.4** (via RVM, rbenv, or asdf)
- **Rails 8.0.2**
- **Node.js 18+ & npm**
- **PostgreSQL 14+**
- **ImageMagick** (required for `FrostedPreviewService` and `ForensicWatermarkService`):
  ```bash
  # macOS
  brew install imagemagick
  # Ubuntu / Debian / WSL
  sudo apt update && sudo apt install -y imagemagick
  ```

### 2. Environment & Dependency Installation
```bash
# Clone and enter repo
git clone <repo-url> creator-marketplace
cd creator-marketplace

# Install Rails gems
bundle install

# Install Fan App PWA dependencies
cd fan-app && npm install && cd ..
```

### 3. Database Setup & Migrations
```bash
# Create databases, run migrations (includes Solid Queue tables) and seed
bin/rails db:create db:migrate db:seed
```

### 4. Running the Applications
Open two terminal tabs:

**Terminal 1 — Rails Backend & Studio (Port 3000):**
```bash
# Always use the project Ruby 3.4.4 environment
~/.rvm/wrappers/ruby-3.4.4/bundle exec rails s
# Or if using rbenv/system Ruby:
bin/rails server -b 0.0.0.0
```

**Terminal 2 — Fan App Next.js PWA (Port 3001):**
```bash
cd fan-app
npm run dev -- -p 3001
```

*(Optional) Terminal 3 — Dedicated Solid Queue Worker:*
```bash
# During standard development, Puma automatically runs Solid Queue via plugin.
# To run dedicated workers or inspect jobs:
bin/rails solid_queue:start
```

---

## 🔑 Test Credentials & Quick Links

| Portal | URL | Credentials / Details |
|---|---|---|
| **Studio Dashboard** | [http://localhost:3000/dashboard](http://localhost:3000/dashboard) | Creator: `ananya@example.com` / `password123` |
| **Studio Sign-In** | [http://localhost:3000/sign_in/email](http://localhost:3000/sign_in/email) | Or phone sign-in at `/sign_in` (OTP logged to console) |
| **Creator Storefront** | [http://localhost:3000/ananyarao](http://localhost:3000/ananyarao) | Public link-in-bio & collections |
| **Fan PWA (Desktop/Mobile)** | [http://localhost:3001/feed](http://localhost:3001/feed) | Fan persona: Priya (`+91 98765 43210`) |
| **PWA Discover** | [http://localhost:3001/discover](http://localhost:3001/discover) | Trending vault drops and creator directory |

---

## 🎯 Next Tasks & Backlog (To Pick Up Next)

When resuming work, here are the prioritized next objectives from [TODO.md](file:///Users/virendrashakya/Development/rails/creator-marketplace/TODO.md):

1. **HLS Segmented Video Streaming**:
   - Replace direct video download URLs with chunked HLS playlists (`.m3u8` + `.ts`/`.m4s`) with short-lived HMAC authorization tokens to prevent 1-click video rip extensions.
2. **Invisible Steganographic Watermarking**:
   - Complement the visible forensic footer banner with subtle DCT/LSB noise watermark embedding buyer ID into pixels.
3. **WhatsApp Business API Gateway Integration**:
   - Plug real Meta Cloud API credentials (`WHATSAPP_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`) to transition from console/flash OTPs to real WhatsApp OTP delivery.
4. **End-to-End Automated Test Suite**:
   - Write system/request specs testing the 12-digit UPI UTR claim submission and creator approval workflow.
5. **Mobile PWA Enhancements**:
   - Add push notifications handling in service worker for live broadcast starts and DM messages.

---

## 📚 Key Reference Documents
- **[REFERENCE.md](file:///Users/virendrashakya/Development/rails/creator-marketplace/REFERENCE.md)**: Master LLM context and single source of truth (models, routes, architecture).
- **[FEATURES.md](file:///Users/virendrashakya/Development/rails/creator-marketplace/FEATURES.md)**: Product features, DRM specs, and 23 architectural chapters.
- **[TODO.md](file:///Users/virendrashakya/Development/rails/creator-marketplace/TODO.md)**: Security roadmap and backlog tracking.
- **[AGENTS.md](file:///Users/virendrashakya/Development/rails/creator-marketplace/AGENTS.md)**: AI coding assistant rules (Ruby 3.4.4, documentation integrity, Obsidian Velvet design tokens).
