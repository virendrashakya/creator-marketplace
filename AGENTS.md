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
