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

## 3. Design System Standard: Dark "Studio" (since 13 Oct 2026)

The light "Indian Modern Editorial Chic" theme was replaced by one dark system, ported from the Claude Design files. `DESIGN.md` and `.agents/rules/design_system.md` describe the old light theme and are kept for history only.

- **Source of truth**: `public/assets/wf.css` (tokens and `w-` components) and `app/helpers/wf_helper.rb` (icons, avatars, cover sources, Studio nav). Screenshots: `docs/screenshots/redesign-2026-10/`.
- **Typography**: **Plus Jakarta Sans** everywhere.
- **Colors**:
  - Page `#0E0E10`, cards `#16161A`, raised `#1C1C20`, lines `#26262A`
  - Text `#F5F5F7`, secondary `#A1A1AA`, muted `#71717A`
  - Ruby pink `#E0306A`: the paid action and active states
  - Gold `#F5B942`: Close Friends and anything the fan already owns
  - Green `#4ADE80`: money received, approved, live
  - Rose `#F87196`: errors and short payments
- **Layouts** (`content_for :chrome`):
  - `fan`: phone-width (≤480px) dark app for everything a fan sees; desktop storefront widens to 960px.
  - `list`: public link-list page; floats over a blurred copy of its cover on desktop.
  - `studio`: creator web app with the 220px sidebar (Overview, Posts, Collections, Shop, Link lists, Book, Payments, Messages, Settings); collapses to a scrolling top strip under 960px.
- **Light theme**: `html[data-theme="light"]` re-points the same tokens (page `#F6F5F2`, cards `#FFFFFF`, text `#17151A`, pink `#D6245F`, gold text `#A86A00`, green `#15803D`). Use tokens, not hex, in new markup so both themes work. Anything over a photo or video stays dark.
- **Rules**: prices appear only where a fan can act on them (never in the Collections grid); the first item of a collection is its public cover; every unlocked image goes through `/paid_media_posts/:id/media`.
