# AI Coding Assistant Rules & Guidelines for Wishful

## 1. Documentation Integrity & Continuous Maintenance (MANDATORY)

Whenever any code, architectural pattern, database schema, route, controller, service, or feature is added, modified, or removed:

- **Always keep the following documentation files updated in the same turn:**
  1. **`REFERENCE.md`**: The primary single source of truth and LLM context guide. Must reflect current state, models, routes, features, and tech stack details.
  2. **`FEATURES.md`**: The detailed product feature and architecture specification.
  3. **`TODO.md`**: Project roadmap, security checklist, and pending/completed backlog tasks.
- **Never let documentation drift from code.** If a route changes in `config/routes.rb` or a model changes in `app/models/`, immediately update the corresponding tables and sections in `REFERENCE.md`.

---

## 2. Platform Conventions & Standards

- **Ruby & Rails**: Ruby 3.4.4, Rails 8.0.2. Always execute bundle and rails commands via the project's Ruby 3.4.4 environment (`~/.rvm/wrappers/ruby-3.4.4/bundle exec ...`).
- **Encodings**: All ERB templates and Ruby files MUST be saved in valid UTF-8. Avoid stray non-UTF-8 characters.
- **Direct UPI & Zero Rake**: The core monetization engine relies on peer-to-peer UPI with 12-digit UTR claims. Keep this architectural principle intact.
- **DRM & Anti-Leak**: Any media delivery feature must adhere to server-side blurred teaser previews (`FrostedPreviewService`) and forensic watermarking (`ForensicWatermarkService`) before exposing assets to clients.

---

## 3. Design System Standard: Obsidian Velvet & Neon Ruby (since 14 Oct 2026)

The design system channels an uncompromising, late-night sensual chic aesthetic—merging high-end editorial luxury with the nocturnal pulse of exclusive VIP nightlife.

- **Source of truth**: `public/assets/wf.css` (Rails Studio & Storefront tokens) and `fan-app/src/app/globals.css` (Next.js PWA tokens).
- **Typography**: **Plus Jakarta Sans** everywhere (`display-hero`, `headline-lg/md/sm`, `body-lg/md/sm`, `label-vip`). Extreme weight contrasts: razor-sharp tight headings against tracked uppercase VIP cues (`letter-spacing: 0.14em`).
- **Colors**:
  - Base Canvas (Z0 Abyss): `#050406`, neutral core `#09080c` with warm violet undertones
  - Surface Layer 1 (Cards & Trays): Smoked velvet `#0e0c12` with 24px backdrop blur and hairline ruby border `rgba(255, 23, 103, 0.12)`
  - Surface Layer 2 (Elevated Sheets & Popovers): `#181520` with 1px border tinted in `rgba(255, 23, 103, 0.12)`
  - Text: Alabaster primary `#fdf2f4`, soft `#e6bcc1`, silky twilight gray muted `#a39aa5`, dim `#716973`
  - Electric Ruby (Primary): `#ff1767`, active action gradient `linear-gradient(135deg, #ff1767 0%, #c026d3 100%)` with radiant neon bloom `box-shadow: 0 4px 20px rgba(255, 23, 103, 0.35)`
  - Secondary: Deep plum-rose velvet `#9d174d`
  - Tertiary: Rose quartz bloom `#fb7185`
  - Gold: `#F5B942` for Close Friends, VIP pass, and already owned assets (`#1E1A10` background with gold glow)
  - Green: `#4ADE80` for money received, approved, live broadcasts
  - Error / Rose: `#ffb4ab`
- **Shapes & Elevation**:
  - Pill silhouette (`rounded-full`, `border-radius: 9999px`) on all buttons, badges, and interactive chips.
  - Floating velvet trays with smoked glass blur (`backdrop-filter: blur(24px)`) and ruby neon ambient glow.
- **Rules**: prices appear only where a fan can act on them; the first item of a collection is its public cover; every unlocked image goes through `/paid_media_posts/:id/media`.
