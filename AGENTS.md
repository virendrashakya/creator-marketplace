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

## 3. Design System Standard: Indian Modern Editorial Chic

- **Brand Token Memory**: Refer to `.agents/rules/design_system.md`.
- **Typography**: Clean, geometric modernism driven entirely by **Plus Jakarta Sans** across display, headlines, bio, Rupee amounts, micro-metadata, navigation bars, and lock badges.
- **Colors**:
  - Primary: `#C2185B` (Sindoor Ruby)
  - Secondary: `#D4AF37` (Zari Gold)
  - Tertiary: `#7A1C3C` (Deep Jamun / Velvet Maroon)
  - Neutral: `#111317` (Kajal Charcoal)
  - Canvas: `#F6F7F5` / `#F9F9FF` (Raw Alabaster Silk)
- **Responsive Viewport Standard**:
  - **Mobile (< 900px)**: 100% full-bleed mobile canvas, top bar with `Wishful` + `CREATOR & FAN` pill, 3-column stats, rich ruby VIP pass, 1-col Vault drops, 2-col Curated Fit Picks, sticky bottom CTA bar.
  - **Desktop (>= 900px)**: 1200px responsive canvas with full top navbar (`CreatorVault`), wide hero cover with overline and camera tag, 4-column stats row, 2-column split (VIP Pass hero + 100% Direct Settlement Guarantee card), 3-column Vault drop cards with cart triggers, 4-column Curated Fit Picks, wide tip box, and desktop footer.
