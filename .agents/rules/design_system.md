---
name: Indian Modern Editorial Chic
colors:
  surface: '#f9f9ff'
  surface-dim: '#d9d9df'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f9'
  surface-container: '#ededf3'
  surface-container-high: '#e8e8ed'
  surface-container-highest: '#e2e2e8'
  on-surface: '#1a1c20'
  on-surface-variant: '#594045'
  inverse-surface: '#2f3035'
  inverse-on-surface: '#f0f0f6'
  outline: '#8d6f75'
  outline-variant: '#e1bec4'
  surface-tint: '#b90c55'
  primary: '#9b0044'
  on-primary: '#ffffff'
  primary-container: '#c2185b'
  on-primary-container: '#ffd9df'
  inverse-primary: '#ffb1c2'
  secondary: '#735c00'
  on-secondary: '#ffffff'
  secondary-container: '#fed65b'
  on-secondary-container: '#745c00'
  tertiary: '#892847'
  on-tertiary: '#ffffff'
  tertiary-container: '#a8405f'
  on-tertiary-container: '#ffd9df'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffd9df'
  primary-fixed-dim: '#ffb1c2'
  on-primary-fixed: '#3f0018'
  on-primary-fixed-variant: '#8f003f'
  secondary-fixed: '#ffe088'
  secondary-fixed-dim: '#e9c349'
  on-secondary-fixed: '#241a00'
  on-secondary-fixed-variant: '#574500'
  tertiary-fixed: '#ffd9df'
  tertiary-fixed-dim: '#ffb1c2'
  on-tertiary-fixed: '#3f0018'
  on-tertiary-fixed-variant: '#812241'
  background: '#f9f9ff'
  on-background: '#1a1c20'
  surface-variant: '#e2e2e8'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '600'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '600'
    lineHeight: 38px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
    letterSpacing: 0em
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
    letterSpacing: -0.01em
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.02em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.04em
  price-editorial:
    fontFamily: Plus Jakarta Sans
    fontSize: 17px
    fontWeight: '800'
    lineHeight: 22px
    letterSpacing: -0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system blends contemporary high-fashion editorial rigor with vibrant Indian sartorial luxury. Tailored for mobile-first creator monetization within Indian fashion, saree draping, glamour, and style curations, the aesthetic moves away from kitsch toward quiet opulence, warm alabaster surfaces, sharp typography, and jewel-tone accents.

### Visual Aesthetic & Language
- **Modern Editorial Luxury:** Inspired by international luxury publications and contemporary Indian couture ateliers (such as Sabyasachi, Raw Mango, and Tarun Tahiliani), combining pristine typography with generous breathing room.
- **Warm Architectural Minimalism:** Light, alabaster-infused canvas layers (`#F6F7F5`) provide a soft, tactile editorial foundation that lets vivid textile photography, silks, and zari work take center stage.
- **Glass & Luster Accents:** Subtle translucent scrims, brushed gold metallic tier badges, and high-impact ruby/crimson CTA triggers elevate micro-transactions into premium patronage experiences.

## Colors

The palette balances modern restraint with rich subcontinental color theory:

- **Primary (`#C2185B` - Sindoor Ruby):** A high-fashion crimson rose used for primary actions, unlock states, active tabs, and priority micro-interactions.
- **Secondary (`#D4AF37` - Zari Gold):** A refined metallic ochre reserved for VIP memberships, close friends tier markers, verified badges, and ceremonial tier indicators.
- **Tertiary (`#7A1C3C` - Deep Jamun / Velvet Maroon):** A grounded wine tone for deep container tints, elevated tags, and subtle gradient borders on exclusive drops.
- **Neutral (`#111317` - Kajal Charcoal):** A deep, warm carbon black delivering high contrast against the backdrop without the sterile harshness of pure black.
- **Canvas Base (`#F6F7F5` - Raw Alabaster Silk):** An off-white, gallery-grade foundation that reduces screen glare while honoring South Asian skin tones and rich textile hues.
- **Surface Elevation (`#FFFFFF` with 80% opacity):** Translucent milk glass for preview cards, bottom sheets, and sticky navigation overlays.

## Typography

The typography relies entirely on Plus Jakarta Sans, delivering clean, geometric modernism and exceptional legibility across all screen sizes for bio copy, Rupee amounts, micro-metadata, navigation bars, and lock badges.

- **Plus Jakarta Sans:** Drives creator display branding, collection titles, spotlight story intros, and interface copy with friendly, geometric clarity.
- **Rupee Glyph Standards:** The ₹ glyph must always render at matching font weight and baseline height with numerical pricing (`price-editorial`).

## Layout & Spacing

Designed primarily for portrait mobile screens within progressive web apps (360px to 430px viewport widths), scaling comfortably to tablet and desktop preview frames.

- **Mobile Viewport Shell:** Maximum content container width of `480px` centered on larger displays to preserve an intimate, phone-first reel browsing experience.
- **Vertical Rhythm:** Strict 4px base increment. Grid gutters set to `1rem` (16px) for 2-column reel lookbook cards.
- **Edge Offsets:** Screen margins fixed at `1rem` (16px) on mobile viewports to maximize visual reel surface while providing touch safety along bezel edges.
- **Safe Area Insets:** Account for `env(safe-area-inset-top)` on creator header bars and `env(safe-area-inset-bottom) + 4rem` to accommodate the floating action bar.

## Elevation & Depth

Visual hierarchy uses frosted glass overlays, subtle warm tinted drop shadows, and delicate borders:

- **Surface Level 0 (Canvas):** Pure `#F6F7F5` base background.
- **Surface Level 1 (Frosted Cards):** Translucent white (`rgba(255, 255, 255, 0.78)`) backed by `backdrop-filter: blur(16px)` and bounded by a hairline border (`rgba(17, 19, 23, 0.06)`).
- **Surface Level 2 (Locked Media Veil):** Gradient scrim over content preview (`linear-gradient(180deg, rgba(17, 19, 23, 0.1) 0%, rgba(17, 19, 23, 0.85) 100%)`) with `backdrop-filter: blur(10px)`.
- **Floating Modals & Bottom Sheets:** `#FFFFFF` with a 24px ambient blur shadow tinted with rich umber (`rgba(17, 19, 23, 0.12)`) and 0px lateral spread.
- **Zari Glow (VIP Tier Cards):** A soft perimeter luminescence (`box-shadow: 0 4px 20px -2px rgba(212, 175, 55, 0.25)`).

## Shapes

The design uses balanced, modern curvature throughout:

- **Base Corner Radius:** `0.5rem` (8px) for buttons, badges, chips, and small interactive targets.
- **Container Radius:** `1rem` (16px) for lookbook cards, wishlist items, and creator cover imagery.
- **Sheet Radius:** `1.5rem` (24px) on top corners of bottom sheets and drawer takeovers.
- **Full Pill (`9999px`):** Reserved for category filters, status pills (e.g., "Unlocked", "Exclusive"), and the sticky checkout drawer CTA.

## Components

### Creator Bio Banner
- **Cover Visual:** Full-bleed 16:9 aspect ratio with subtle bottom gradient fade into `#F6F7F5`.
- **Avatar & Verification:** Circular 84px avatar offset across the cover boundary, bordered by a 3px alabaster ring. Verified badge renders in Zari Gold (`#D4AF37`) with a crisp white checkmark.
- **Handle & Location Pill:** Clean display creator title, followed by an Instagram handle badge with city marker (e.g., "Mumbai • Bandra West").

### Tabbed Segment Switcher
- Horizontal scroll-free 4-tab bar:
  1. **The Vault:** Exclusive unreleased styling reels & behind-the-scenes.
  2. **Fits & Looks:** Shoppable saree, drape, and lehenga curations with direct sourcing links.
  3. **Spoil Me Wishlist:** Fan and admirer gift pledges & milestone contributions.
  4. **VIP Access:** Monthly close friends pass for private broadcast group & DM priorities.
- Active tab indicated by Ruby `#C2185B` indicator and bold label typography; inactive tabs display in muted charcoal (`rgba(17, 19, 23, 0.55)`).

### Frosted Preview Cards & Rupee Pricing
- 4:5 vertical portrait aspect ratio optimized for Indian ethnic reel thumbnails.
- Translucent frosted glass bottom shelf detailing look title, drape technique, and lock status.
- Price displayed as `₹499`, `₹1,499`, or `₹2,999/mo` in high-contrast `price-editorial` styling.
- Lock pill badge anchored at top-right corner using a frosted dark scrim with a gold key or lock icon.

### VIP Close Friends Pass Callout
- Premium hero card wrapped in an ultra-subtle gold hairline border (`1px solid rgba(212, 175, 55, 0.4)`).
- Background features a light champagne gradient (`linear-gradient(135deg, #FFFFFF 0%, #FAF6EE 100%)`).
- Perks presented with miniature checkmark icons in rich wine (`#7A1C3C`).

### Sticky Mobile CTA
- Anchored to the mobile viewport base with 16px bottom and side padding.
- Pill-shaped capsule containing:
  - Left slot: Micro-tier avatar stack or dynamic item total ("1 Look Selected: ₹299").
  - Right slot: Ruby button (`#C2185B`) with bold white copy ("Unlock Instantly via UPI / Card").
- Integrates backdrop blur behind the container to keep scrolling content readable beneath.
