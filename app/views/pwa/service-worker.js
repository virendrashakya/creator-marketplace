/* Wishful service worker.

   Three jobs:
     1. Offline. Pages are network-first; when the network is gone, the last
        copy of a page is served, and failing that the /offline page.
     2. Saved unlocks (7e). Watermarked media a fan has already opened is
        kept in its own cache, so it still opens on a plane. It is the same
        watermarked copy, so keeping it does not weaken the leak protection.
     3. Push (7c). Shows notifications and opens the right page on tap.

   Payments and anything that writes are never cached: a POST always goes
   to the network or fails visibly. */

const VERSION = "wf-v1";
const SHELL = `${VERSION}-shell`;
const PAGES = `${VERSION}-pages`;
const MEDIA = "wf-unlocks"; // kept across versions on purpose

const SHELL_URLS = [
  "/offline",
  "/assets/wishful.css",
  "/assets/wf.css",
  "/assets/js/wf.js",
  "/assets/js/turbo.min.js",
  "/icon-192.png",
  "/icon.svg"
];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(SHELL).then((cache) => cache.addAll(SHELL_URLS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k.startsWith("wf-v") && !k.startsWith(VERSION)).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

function isMedia(url) {
  return /^\/paid_media_posts\/\d+\/media$/.test(url.pathname);
}

self.addEventListener("fetch", (event) => {
  const req = event.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;
  if (url.pathname.startsWith("/cable") || url.pathname.startsWith("/pay/")) return;

  // Unlocked media: network first (so a revoked unlock is noticed), then
  // the saved copy when offline.
  if (isMedia(url)) {
    event.respondWith(
      fetch(req).then((res) => {
        if (res.ok) {
          const copy = res.clone();
          caches.open(MEDIA).then((cache) => cache.put(url.pathname, copy));
        }
        return res;
      }).catch(() => caches.match(url.pathname, { cacheName: MEDIA }).then((hit) => hit || Response.error()))
    );
    return;
  }

  if (url.pathname.startsWith("/assets/") || /\.(png|svg|jpg|webp)$/.test(url.pathname)) {
    event.respondWith(
      caches.match(req).then((hit) => hit || fetch(req).then((res) => {
        if (res.ok && url.pathname.startsWith("/assets/")) {
          const copy = res.clone();
          caches.open(SHELL).then((cache) => cache.put(req, copy));
        }
        return res;
      }))
    );
    return;
  }

  if (req.mode === "navigate") {
    event.respondWith(
      fetch(req).then((res) => {
        if (res.ok && (url.pathname === "/unlocks" || /^\/[a-z0-9_]+\/(c|d)\/\d+/.test(url.pathname))) {
          const copy = res.clone();
          caches.open(PAGES).then((cache) => cache.put(url.pathname + url.search, copy));
        }
        return res;
      }).catch(() =>
        caches.match(url.pathname + url.search, { cacheName: PAGES })
          .then((hit) => hit || caches.match(url.pathname, { cacheName: PAGES }))
          .then((hit) => hit || caches.match("/offline"))
      )
    );
  }
});

self.addEventListener("push", (event) => {
  let data = {};
  try { data = event.data ? event.data.json() : {}; } catch (e) { data = { title: "Wishful", body: event.data && event.data.text() }; }
  event.waitUntil(
    self.registration.showNotification(data.title || "Wishful", {
      body: data.body || "",
      icon: "/icon-192.png",
      badge: "/icon-192.png",
      tag: data.tag,
      data: { url: data.url || "/" }
    }).then(() => (self.navigator.setAppBadge ? self.navigator.setAppBadge(1) : null)).catch(() => {})
  );
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const target = new URL((event.notification.data && event.notification.data.url) || "/", self.location.origin).href;
  event.waitUntil(
    self.clients.matchAll({ type: "window", includeUncontrolled: true }).then((wins) => {
      if (self.navigator.clearAppBadge) self.navigator.clearAppBadge().catch(() => {});
      for (const w of wins) {
        if (w.url === target && "focus" in w) return w.focus();
      }
      return self.clients.openWindow(target);
    })
  );
});
