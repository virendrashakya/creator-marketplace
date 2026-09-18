# Wishful — design brief

Design a creator monetization platform from scratch. Below is everything the
product does. Design all of it. Nothing here is optional or placeholder.

---

## 1. What this is

**Wishful** is a link-in-bio and monetization platform for **Indian creators**.
A creator builds one public page holding everything they recommend and sell.
Their audience browses it and pays them.

The distinguishing mechanic: **payments settle over UPI, by hand.**

1. A fan taps a paid item and lands on a payment screen showing the creator's
   UPI ID and QR code.
2. The fan pays from their own UPI app (GPay, PhonePe, Paytm).
3. The fan returns and submits the **UTR** (the 12-digit reference number their
   UPI app shows) plus an optional screenshot.
4. The claim sits **pending**. The creator opens a review queue, checks the UTR
   against their bank statement, and **approves or rejects**.
5. Approval grants access instantly.

No payment gateway. No card fields. The whole product runs on a trust handshake
between two people, and the interface has to carry that trust.

**Audience:** Indian creators, roughly 19–30, phone-first, Instagram and YouTube
native. Their fans are the same. Money is in **rupees**, grouped the Indian way
(₹1,20,000 and ₹1,00,00,000 — lakh and crore, not 120,000).

---

## 2. The problem to solve

The current build is functionally complete but visually flat: dense text rows,
almost no imagery, no feedback on interaction, no sense of progress or reward.
A creator opens the dashboard and sees paragraphs where they should see their
work. It feels like a spreadsheet, not like a place they are proud to send
people.

**Design for:**
- A creator who wants their page to feel like *theirs* and worth sharing.
- A fan who has to feel safe sending money to a stranger with no gateway.
- Phones first. Most of both audiences will never see this on a desktop.

---

## 3. Every screen to design

### Public / signed out

**Home (marketing).** Explains the product, drives signup. Currently a hero plus
three feature blurbs.

**Sign up.** Name, handle (the public address, `wishful.app/@handle`, lowercase
letters/numbers/underscores, max 30), email, password, password confirmation.

**Sign in.** Email, password.

**Creator public profile — `/@handle`.** The most important screen. One page
holding every section below, in this order, each hidden when empty:

- **Identity:** banner image, avatar, display name, @handle, category and
  subcategory, pronouns, location, bio, social buttons (Instagram, YouTube, X,
  Reddit, TikTok, website).
- **Recommendations**, grouped into named collections plus an ungrouped set.
  Each: image, title, merchant, price (free text like "₹2,499"), the creator's
  written reason for recommending it, and a "featured" flag that pins it. Taps
  redirect out through a click-tracking URL.
- **Paid media.** Photo or video behind a one-time unlock. Shows a blurred
  preview until purchased; unlocked state reveals the real media.
- **Meetups.** A paid offer (title, description, location, duration, price) with
  bookable time slots. Slots show as individual times; booked ones disappear.
- **Contact reveals.** Pay to see a hidden contact detail (a WhatsApp number,
  an email). Locked until the creator approves payment, then revealed.
- **Gift wishlists.** Items the audience funds toward a target. Each shows a
  progress meter, amount raised vs. target, and a gift action. Supports partial
  contributions with an optional note. Items become "funded" at 100%.
- **Posts.** A social feed: text, optional photo or video, like button, comment
  thread with inline comment box.

**Payment screen.** Creator's UPI QR and UPI ID, payee name, amount due, and a
form: UTR number, optional screenshot upload, amount actually sent, optional
note. Must make a manual, slightly slow process feel safe rather than sketchy.

### Signed in — creator side

**Dashboard.** The home base. Today it's a wall of links. Needs to show:
- Stats: recommendation count, total link clicks, revenue.
- A prominent alert when payment claims are waiting for review.
- Managed lists, each with create/edit/delete: collections, recommendations,
  subscription plans, gift wishlists, meetups + contact reveals, paid media.
- Entry points to eleven different "create" actions. Today these are eleven
  identical buttons in a row — solve this.

**Payment review queue.** Pending claims, each showing: who paid, amount due,
what they bought, when, the UTR, their note, their screenshot, and a **warning
when the amount they claim to have sent differs from the amount due**. Approve
and reject actions. Plus a list of recently reviewed claims with their outcome.

**Creator settings.** One long form, roughly 40 fields in five groups:
- *Account:* display name, email, account type (creator/personal/business),
  date of birth.
- *Public profile:* bio, profile picture, banner, pronouns, location, public
  contact email.
- *Category and style:* creator category (Fashion, Beauty, Fitness, Travel,
  Food, Gaming, Lifestyle, Art & design, Music, Adult creator), subcategory,
  **page theme** (Minimal, Luxury, Adventure, After dark), **page layout**
  (List, Editorial, Gallery).
- *Payments:* UPI ID, payee name shown to fans, UPI QR upload, and a toggle to
  accept UPI payments.
- *Social links:* the six handles above.

**Create/edit forms** for: collection, recommendation, post, paid media, paid
media collection, subscription plan, meetup (plus a slot manager), contact
reveal, wishlist, wishlist item.

**Blocked accounts.** A creator can block people by identifier, with a reason.

---

## 4. Non-negotiable product mechanics

**Themes.** Four creator-selectable themes (Minimal, Luxury, Adventure, After
dark) that restyle the public profile only. Design all four. Two are dark.
Structure must not change between them, only color and surface.

**Layouts.** Three creator-selectable profile layouts — List, Editorial,
Gallery. Design all three.

**Money.** Amounts are stored in the currency's minor unit (paise). Creators
enter prices in paise, which is a known trap: someone typing "499" meaning ₹499
would charge ₹4.99. The price input has to make the unit unmistakable. Supports
INR and USD; rupees use lakh/crore grouping.

**Payment states.** Pending, approved, rejected. These need a visual grammar
used consistently everywhere. Also: hidden/published, unlocked/locked,
booked/open, funded/still-needed.

**Time.** All times are IST and must show the timezone. Meet slots are real
dates.

**Every list needs a real empty state.** A new creator sees roughly six of them
at once. These are the first thing they experience — make them invitations, not
apologies.

---

## 5. Design direction

Open. The current build uses a cool "passbook" neutral with a single marigold
accent (the color of Indian gifting), a serif display face, and rows rather than
cards. Take it or replace it — but ground the direction in **this** product for
**this** audience, not in generic creator-economy or SaaS defaults.

What matters more than any particular palette:

- **Make the page feel worth sharing.** A creator should want to put this link
  in their bio.
- **Make paying feel safe.** The UTR, the amount, the confirmation state — this
  is a receipt, and receipts are a real visual language.
- **The recommendation is a sentence, not a product listing.** What makes this
  different from a shop is that the creator says *why*. Give those words weight.
- **Imagery and interaction over text density.** Every list currently reads as
  text. Show the thing.
- **Feedback on every action.** Pressed states, loading states, progress,
  confirmation. Nothing should feel inert.

### Constraints that are not style preferences

- **Phone-first**, down to 360px. Full-bleed layouts need notch-safe insets.
- **Accessible:** WCAG AA contrast minimum in all four themes and both modes.
  Visible keyboard focus. Real labels on every input. 44px touch targets.
- **Honor `prefers-reduced-motion`.**
- **Handles, reference codes and brand names must not be auto-translated.**
- **Long user content must not break layout** — bios, titles, notes, comments
  and pasted URLs all need truncation or wrapping.
- **Numbers that get compared** (money, counts, clicks) need tabular figures.

### Avoid

Templated defaults: three equal feature cards, uppercase tracked-out eyebrow
labels above every heading, meta strings joined with middle dots, `01 / 02 / 03`
step markers on content that isn't a sequence, purple-blue AI gradients, the
warm beige-and-brass palette that every premium consumer site reaches for, and
em dashes in UI copy.

---

## 6. Deliverables

For each screen in section 3: mobile and desktop. Plus:

- The design system itself — color tokens, type scale, spacing, radii, states.
- All four profile themes and all three layouts.
- Component specs: buttons (primary/secondary/destructive/disabled), form
  fields, the money input, selects, file uploads with preview, the state badges,
  cards/rows, progress meters, empty states, the payment claim card, toasts.
- Every state: empty, loading, error, success, locked, unlocked, pending.
